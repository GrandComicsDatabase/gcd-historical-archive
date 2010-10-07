import hashlib
from datetime import datetime

from django.conf import settings
from django.db.models import Q
from django.core import urlresolvers
from django.core.mail import send_mail
from django.http import HttpResponseRedirect
from django.template import RequestContext
from django.shortcuts import render_to_response, get_object_or_404
from django.contrib.auth.decorators import login_required, permission_required

from apps.gcd.views import render_error
from apps.voting.models import *

EMAIL_RESULT = """
All ballots have been received for the following topic from the %s agenda:

  %s

The results are:

%s

Please go to %s for more details.
"""

EMAIL_RECEIPT = """
This is your reciept for your vote in the secret ballot election for %s.
You voted for:
%s

If anything has gone wrong with your vote, or if the election allows you to
change your vote and you wish to change it, you will need to provide the
following two pieces of information to the voting administrator in order to
match account to your votes.  Note that changing your vote may require you to
disclose your vote choices to the voting administrator.

secret key:
'%s'
vote id:
'%s'
"""

def dashboard(request):
    topics = Topic.objects.filter(deadline__gte=datetime.now(), open=True)

    # Permissions are returned as appname.codename by get_all_permissions().
    if request.user.is_anonymous:
        my_topics = ()
        other_topics = topics
    else:
        codenames = [p.split('.', 1)[1] for p in request.user.get_all_permissions()]
        can_vote = Q(agenda__permission__codename__in=codenames)
        my_topics = topics.filter(can_vote)
        other_topics = topics.exclude(can_vote)

    return render_to_response('voting/dashboard.html', 
                              {
                                'topics': topics,
                                'agendas': Agenda.objects.all(),
                              },
                              context_instance=RequestContext(request))

def _calculate_results(unresolved):
    """
    Given a QuerySet of unresolved topics (with expired deadlines),
    resolve them into results, possibly indicating a tie of some sort.

    TODO: Handle ranked choice voting.
    TODO: Handle the case of abstaning being a "winning" option.
    """

    for topic in unresolved:
        # if topic.agenda.quorum:
            # raise Exception, '%d / %d' % (topic.agenda.quorum, topic.num_voters())
        if topic.agenda.quorum and topic.num_voters() < topic.agenda.quorum:
            # Mark invalid with no results.  Somewhat counter-intuitively,
            # we consider the results to have been "calculated" in this case
            # (specifically, we calculated that there are no valid results).
            topic.invalid = True
            topic.result_calculated = True
            topic.save()
            continue

        # Currently, proceed with results even if there are fewer results
        # than expected.  It is conceivable that this is a valid outcome,
        # for instance, if only three candidates receive any votes in a Board
        # election, then there should be only three winners even though there
        # are four or five positions.

        options = topic.counted_options().filter(num_votes__gt=0)
        num_options = options.count()

        if topic.vote_type.max_votes <= topic.vote_type.max_winners:
            # Flag ties that affect the validity of the results,
            # and set any tied options after the valid winning range
            # to a "winning" result as well, indicating that they are all
            # equally plausible as winners despite producing more winners
            # than are allowed.
            i = topic.vote_type.max_winners
            while (i > 0 and i < num_options and
                   options[i-1].num_votes == options[i].num_votes):
                topic.invalid = True

                # Note that setting options[i].result = True and then
                # saving options[i] does not work, probably as a side effect
                # of evaluationg the options queryset (it's not actualy an array)
                option = options[i]
                option.result = True
                option.save()
                i += 1

            # Set all non-tied winning results.
            for option in options[0:topic.vote_type.max_winners]:
                option.result = True
                option.save()

            topic.result_calculated = True
            topic.save()

            _send_result_email(topic)

        else:
            # TODO: Implement Schulze method.
            pass

def _send_result_email(topic):
    for list_config in topic.agenda.agenda_mailing_lists.all():
        if list_config.on_vote_close:
            if topic.invalid:
                result = ('This vote failed to produce a valid result.  '
                          'The vote administrators will follow up as needed.')
            elif topic.vote_type.name == TYPE_PASS_FAIL:
                if topic.options.get(result=True).name == 'For':
                    result = 'The motion PASSED'
                else:
                    result = 'The motion FAILED'

            else:
                result = 'The following option(s) won:\n'
                for winner in topic.options.filter(result=True):
                    result += '  * %s\n' % winner.name

            email_body = EMAIL_RESULT % (topic.agenda, topic.text, result,
              settings.SITE_URL.rstrip('/') + topic.agenda.get_absolute_url())

            send_mail(from_email=settings.EMAIL_VOTING_FROM,
                      recipient_list=[list_config.mailing_list.address],
                      subject="GCD Vote Result: %s" % topic,
                      message=email_body,
                      fail_silently=(not settings.BETA))

@login_required
def topic(request, id):
    topic = get_object_or_404(Topic, id=id)

    voted = False
    votes = []
    if not request.user.has_perm('gcd.can_vote'):
        return render_error(request,
                            'You do not have permission to vote on this topic.')
        
    votes = topic.options.filter(votes__voter=request.user)
    receipts = topic.receipts.filter(voter=request.user)
    voted = votes.count() > 0 or receipts.count() > 0

    return render_to_response('voting/topic.html',
                              {
                                'topic': topic,
                                'voted': voted,
                                'votes': votes,
                                'closed': topic.deadline < datetime.now(),
                              },
                              context_instance=RequestContext(request))

@permission_required('gcd.can_vote')
def vote(request):
    if request.method != 'POST':
        return render_error(request,
                            'Please access this page through the correct form.')

    first = True
    topic = None
    voter = None
    option_params = request.POST.getlist('option')
    options = Option.objects.filter(id__in=option_params)

    # Get all of these now because we may need to iterate twice.
    options = options.select_related('topic__agenda', 'topic__vote_type').all()
    for option in options:
        if first is True:
            first = False
            topic = option.topic

            if topic.token is not None and \
               request.POST['token'].strip() != topic.token:
                return render_error(request,
                  'You must supply an authorization token in order '
                  'to vote on this topic.')

            if len(option_params) > topic.vote_type.max_votes:
                plural = 's' if len(option_params) > 1 else ''
                return render_error(request,
                  'You may not vote for more than %d option%s' %
                  (topic.vote_type.max_votes, plural))

            if not topic.agenda.secret_ballot:
                voter = request.user

        # Ranked voting not yet supported (no UI) so just set rank to None.
        vote = Vote(option=option, voter=voter, rank=None)
        vote.save()

    if topic.agenda.secret_ballot:
        # We email the salt and the vote string to the voter, and store
        # the receipt key in the database.  This way they can prove that
        # they voted a particular way by sending us back those two values,
        # and repair or change a vote.
        vote_ids = ', '.join(option_params)
        salt = hashlib.sha1(str(random())).hexdigest()[:5]
        key = hashlib.sha1(salt + vote_ids).hexdigest()

        receipt = Receipt(voter=request.user,
                          topic=option.topic,
                          vote_key=key)
        receipt.save()

        vote_values = "\n".join([unicode(o) for o in options])
        send_mail(from_email=settings.EMAIL_VOTING_FROM,
                  recipient_list=[request.user.email],
                  subject="GCD secret ballot receipt",
                  message=EMAIL_RECEIPT % (topic, vote_values, salt, vote_ids),
                  fail_silently=(not settings.BETA))

    return HttpResponseRedirect(urlresolvers.reverse('ballot',
      kwargs={ 'id': option.topic.id }))

def agenda(request, id):
    agenda = get_object_or_404(Agenda, id=id)

    past_due = Q(deadline__lte=datetime.now())
    open = agenda.topics.exclude(past_due)
    closed = agenda.topics.filter(past_due)

    pending_items = agenda.items.filter(state__isnull=True)
    open_items = agenda.items.filter(state=True)

    _calculate_results(closed.filter(result_calculated=False))

    return render_to_response('voting/agenda.html',
                              {
                                'agenda': agenda,
                                'closed_topics': closed.order_by('-deadline'),
                                'open_topics': open.order_by('-deadline'),
                                'open_items': open_items,
                                'pending_items': pending_items,
                              },
                              context_instance=RequestContext(request))

