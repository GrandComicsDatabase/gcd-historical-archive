import sha
from random import random

from django.conf import settings
from django.db import models
from django.db.models import Count
from django.core import urlresolvers
from django.core.mail import send_mail
from django.contrib.auth.models import User, Permission

TYPE_PASS_FAIL = 'Pass / Fail'

EMAIL_OPEN_BALLOT = """
The topic:

  %s

is now open for voting at:

%s

%s
"""

EMAIL_TOKEN_STRING = """
You will need to enter the following token exactly as shown in order to vote:

%s

Please do not share this token with anyone who did not recieve the email.
Voters who can be shown to not have been eligible to receive the token will
have their votes invalidated.
"""

class MailingList(models.Model):
    class Meta:
        db_table = 'voting_mailing_list'
    address = models.EmailField()
    def __unicode__(self):
        return self.address

class Agenda(models.Model):
    name = models.CharField(max_length=255)
    permission = models.ForeignKey(Permission,
      limit_choices_to={'codename__in': ('can_vote', 'on_board')})

    uses_tokens = models.BooleanField(default=False)
    allows_abstentions = models.BooleanField(default=False)
    quorum = models.IntegerField(null=True, blank=True)
    secret_ballot = models.BooleanField(default=False)

    subscribers = models.ManyToManyField(User, related_name='subscribed_agendas',
                                               editable=False)
    def get_absolute_url(self):
        return urlresolvers.reverse('agenda', kwargs={'id': self.id})

    def __unicode__(self):
        return self.name

class AgendaItem(models.Model):
    class Meta:
        db_table = 'voting_agenda_item'
    name = models.CharField(max_length=255)
    agenda = models.ForeignKey(Agenda, related_name='items')
    notes = models.TextField(null=True, blank=True)
    owner = models.ForeignKey(User, null=True, blank=True,
                                    related_name='agenda_items')
    open = models.BooleanField(default=True)
    created = models.DateTimeField(auto_now_add=True, db_index=True, editable=False)
    updated = models.DateTimeField(null=True, auto_now=True, editable=False)

    subscribers = models.ManyToManyField(User, related_name='subscribed_items',
                                               editable=False)
    def __unicode__(self):
        return self.name

class AgendaMailingList(models.Model):
    class Meta:
        db_table = 'voting_agenda_mailing_list'
    agenda = models.ForeignKey(Agenda, related_name='agenda_mailing_lists')
    mailing_list = models.ForeignKey(MailingList,
                                     related_name='agenda_mailing_lists')
    on_vote_open = models.BooleanField()
    on_vote_close = models.BooleanField()
    reminder = models.BooleanField()
    display_token = models.BooleanField(default=False)

class VoteType(models.Model):
    """
    Determines how to count the votes.
    """
    class Meta:
        db_table = 'voting_vote_type'

    name = models.CharField(max_length=255)
    max_votes = models.IntegerField(default=1, null=True, blank=True,
      help_text='Having more votes than winners sets up ranked choice voting.  '
                'Leave max votes blank to allow as many ranks as options.')
    max_winners = models.IntegerField(default=1,
      help_text='Having more than one winner allows votes to be cast for up to '
                'that many options.')

    def __unicode__(self):
        return self.name

class Topic(models.Model):
    class Meta:
        ordering = ('created',)

    name = models.CharField(max_length=255)
    text = models.TextField(null=True, blank=True)
    agenda_items = models.ManyToManyField(AgendaItem, related_name='topics',
      limit_choices_to={'open': True})
    agenda = models.ForeignKey(Agenda, related_name='topics')
    vote_type = models.ForeignKey(VoteType, related_name='topics',
      help_text='Pass / Fail types will automatically create their own Options '
                'if none are specified directly.  For other types, add Options '
                'below.')
    author = models.ForeignKey(User, related_name='topics')
    second = models.ForeignKey(User, null=True, blank=True,
                                     related_name='seconded_topics')

    created = models.DateTimeField(auto_now_add=True, db_index=True, editable=False)
    deadline = models.DateTimeField(db_index=True)

    token = models.CharField(max_length=255, null=True, editable=False)

    result_calculated = models.BooleanField(default=False, editable=False,
                                            db_index=True)
    invalid = models.BooleanField(default=False, editable=False)

    subscribers = models.ManyToManyField(User, related_name='subscribed_topics',
                                               editable=False)

    def get_absolute_url(self):
        """
        Note that the primary page for a topic is known as the ballot page.
        """
        return urlresolvers.reverse('ballot', kwargs={'id': self.id})

    def counted_options(self):
        """
        Return the options with their vote counts.
        """
        return \
          self.options.annotate(num_votes=Count('votes')).order_by('-num_votes')

    def num_voters(self):
        """
        Returns the number of distinct voters who voted on the topic.
        Primarily used to determine if a quorum has been reached.
        """
        return User.objects.filter(votes__option__topic=self).distinct().count()

    def __unicode__(self):
        return self.name

def topic_pre_save(sender, **kwargs):
    """
    Callback to initialize the token and/or create standard options if needed.
    Note that this function must be defined outside of any class.
    """
    topic = kwargs['instance']
    if topic.agenda.uses_tokens and topic.token is None:
        salt = sha.new(str(random())).hexdigest()[:5]
        topic.token = sha.new(salt + topic.name).hexdigest()

def topic_post_save(sender, **kwargs):
    topic = kwargs['instance']
    if topic.vote_type.name == TYPE_PASS_FAIL and topic.options.count() == 0:
        topic.options.create(name='For', ballot_position=0)
        topic.options.create(name='Against', ballot_position=1)
        if topic.agenda.allows_abstentions:
            topic.options.create(name='Abstain', ballot_position=2)

    # TODO: This is an unfriendly way to handle the situation, but since the
    #       error will only occur in the admin UI, it is sufficient for now.
    for item in topic.agenda_items.all():
        if item not in topic.agenda.items.all():
            raise ValueError(
              "Only items from this topic's agenda may be attached to this topic.")

    if not kwargs['created']:
        # We're done, the rest of the method handles new objects so
        # let's not deal with an extra indentation level.
        return

    # Send mail that we have a new ballot up for vote.
    for list_config in topic.agenda.agenda_mailing_lists.all():
        if list_config.on_vote_open:
            token_string = ''
            if topic.token and list_config.display_token:
                token_string = EMAIL_TOKEN_STRING % topic.token

            email_body = EMAIL_OPEN_BALLOT % (
              topic.text,
              settings.SITE_URL.rstrip('/') + topic.get_absolute_url(),
              token_string)

            send_mail(from_email=settings.EMAIL_VOTING_FROM,
                      recipient_list=[list_config.mailing_list.address],
                      subject="GCD Ballot Open: %s" % topic,
                      message=email_body,
                      fail_silently=(not settings.BETA))

models.signals.pre_save.connect(topic_pre_save, sender=Topic)
models.signals.post_save.connect(topic_post_save, sender=Topic)

class Option(models.Model):
    class Meta:
        ordering = ('ballot_position', 'name',)
        # order_with_respect_to = 'topic'

    name = models.CharField(max_length=255)
    text = models.TextField(null=True, blank=True)
    ballot_position = models.IntegerField(null=True, blank=True,
      help_text='Optional whole number used to arrange the options in an '
                'order other than alphabetical by name.')
    topic = models.ForeignKey('Topic', null=True, related_name='options')
    voters = models.ManyToManyField(User, through='Vote',
                                          related_name='voted_options')
    result = models.NullBooleanField(blank=True)

    def __unicode__(self):
        return self.name

class Vote(models.Model):
    voter = models.ForeignKey(User, related_name='votes')
    option = models.ForeignKey(Option, related_name='votes')
    rank = models.IntegerField(null=True)
    created = models.DateTimeField(auto_now_add=True, editable=False)
    updated = models.DateTimeField(null=True, auto_now=True, editable=False)

    def __unicode__(self):
        string = u'%s: %s' % (self.voter.indexer, self.option)
        if self.rank is not None:
            return string + (' %d' % self.rank)
        return string


