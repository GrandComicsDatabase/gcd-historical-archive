# -*- coding: utf-8 -*-
import re
import sha
from random import random
from datetime import date, timedelta

from django.core import urlresolvers
from django.core.mail import send_mail
from django.conf import settings
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.contrib.auth import authenticate, logout
from django.contrib.auth.models import User, Group
from django.contrib.auth.views import login as standard_login
from django.utils.safestring import mark_safe

from apps.gcd.views import render_error
from apps.gcd.models import Indexer, Language, Country, Reservation, IndexCredit
from apps.gcd.forms.accounts import ProfileForm, RegistrationForm

def login(request, template_name):
    """
    Do some pre-checking before handing off to the standard login view.
    If anything goes wrong just let the standard login handle it.
    """
    try:
        if request.method == "POST":
            user = User.objects.get(username=request.POST['username'])
            if user.indexer.registration_key is not None:
                if date.today() > (user.indexer.registration_expires +
                                   timedelta(1)):
                    return render_error(request,
                      ('This account was never confirmed and has expired.  '
                       'It will be deleted, after which you may re-register.  '
                       'If you would like to re-register sooner, please email '
                       '%s') % settings.EMAIL_CONTACT)
                return render_error(request,
                  ('This account has not yet been confirmed. You should '
                   'receive an email that gives you a URL to visit '
                   'to confirm your account.  After you have visited that URL '
                   'you will be able to log in and use your account.  Please '
                   'email %s if you do not receive the email within a few '
                   'hours.') %
                  settings.EMAIL_CONTACT)

            if 'next' in request.POST:
                next = request.POST['next']
                if re.match(r'/accounts/confirm/', next, flags=re.I):
                    post = request.POST.copy()
                    post['next'] = urlresolvers.reverse('welcome')
                    request.POST = post
    except Exception:
        pass
    return standard_login(request, template_name=template_name)

def register(request):
    """
    Handle the registration form.

    On a GET, display the form.
    On a POST, register the new user, set up their profile, and log them in
    (logging the current user out if necessary).
    """

    if request.method == 'GET':
        form = RegistrationForm(auto_id=True)
        return render_to_response('gcd/accounts/register.html',
          { 'form' : form },
          context_instance=RequestContext(request))
        
    errors = []
    form = RegistrationForm(request.POST)
    if not form.is_valid():
        return render_to_response('gcd/accounts/register.html',
                                  { 'form': form },
                                  context_instance=RequestContext(request))

    cd = form.cleaned_data
    if settings.BETA:
        email_users = User.objects.filter(email=cd['email'])
        if email_users.count():
            return handle_existing_account(request, email_users)

    new_user = User.objects.create_user(cd['email'],
                                        cd['email'],
                                        cd['password'])
    new_user.first_name = cd['given_name']
    new_user.last_name = cd['family_name']
    new_user.is_active = False
    new_user.save()

    new_user.groups.add(*Group.objects.filter(name='indexer'))

    salt = sha.new(str(random())).hexdigest()[:5]
    key = sha.new(salt + new_user.email).hexdigest()
    expires = date.today() + timedelta(settings.REGISTRATION_EXPIRATION_DELTA)
    indexer = Indexer(is_new=True,
                      max_reservations=settings.RESERVE_MAX_INITIAL,
                      max_ongoing=settings.RESERVE_MAX_ONGOING_INITIAL,
                      country=cd['country'],
                      interests=cd['interests'],
                      registration_key=key,
                      registration_expires=expires,
                      user=new_user)
    indexer.save()

    if cd['languages']:
        indexer.languages.add(*cd['languages'])

    email_body = """
Hello from the %s!

  We've received a request for an account with username "%s" using this
email address.  If you did indeed register an account with us,
please confirm your account by going to:

%s

within the next %d days.

  If you did not register for an account, then someone else is trying to
user your email address.  In that case, simply do not confirm the account
and it will expire after %d days.

  If you want to confirm your account after it expires, please email
%s
and we will look into it for you.

thanks,
-the %s team
%s
""" % (settings.SITE_NAME,
       new_user.username,
       settings.SITE_URL.rstrip('/') +
         urlresolvers.reverse('confirm', kwargs={ 'key': key }),
       settings.REGISTRATION_EXPIRATION_DELTA,
       settings.REGISTRATION_EXPIRATION_DELTA,
       settings.EMAIL_CONTACT,
       settings.SITE_NAME,
       settings.SITE_URL)

    send_mail(from_email=settings.EMAIL_NEW_ACCOUNTS_FROM,
              recipient_list=[new_user.email],
              subject='GCD new account confirmation',
              message=email_body,
              fail_silently=(not settings.BETA))

    return HttpResponseRedirect(urlresolvers.reverse('confirm_instructions'))

def confirm_account(request, key):
    try:
        indexer = Indexer.objects.get(registration_key=key)
        if date.today() > indexer.registration_expires:
            return render_error(request,
              mark_safe(('Your confirmation key has expired.  Please email '
                         '<a href="mailto:%s">%s</a> if you would still '
                         'like to activate this account.') %
                        (settings.EMAIL_CONTACT, settings.EMAIL_CONTACT)))

        indexer.user.is_active = True
        indexer.user.save()
        indexer.registration_key = None
        indexer.registration_expires = None
        indexer.save()

        email_body = """
We have a new Indexer!

Username: %s
Name: %s
Email: %s
Country: %s
Languages: %s
Interests:
   %s

Mentor this indexer: %s
        """ % (indexer.user.username,
               indexer,
               indexer.user.email,
               indexer.country.name,
               ', '.join([lang.name for lang in indexer.languages.all()]),
               indexer.interests,
               'http://' + request.get_host() +
               urlresolvers.reverse('mentor',
                                    kwargs={ 'indexer_id': indexer.id }))

        send_mail(from_email=settings.EMAIL_NEW_ACCOUNTS_FROM,
                  recipient_list=[settings.EMAIL_EDITORS],
                  subject='New Indexer: %s' % indexer,
                  message=email_body,
                  fail_silently=(not settings.BETA))

        return HttpResponseRedirect(urlresolvers.reverse('welcome'))

    except Indexer.DoesNotExist:
        return render_error(request,
          ('Invalid confirmation URL.  Please make certain that you copied '
           'the URL from the email correctly.  If it has been more than %d '
           'days, the confirmation code has expired and the account may have '
           'been deleted due to lack of confirmation.') %
          (settings.REGISTRATION_EXPIRATION_DELTA + timedelta(1)))

    except Indexer.MultipleObjectsReturned:
        return render_error(request,
          ('There is a problem with your confirmation key.  Please email %s '
           'for assistance.') % settings.EMAIL_CONTACT)

def handle_existing_account(request, users):
    if users.count() > 1:
        # There are only a few people in this situation, all of whom are
        # either editors themselves or definitely know how to easily get
        # in touch with an editor.
        return render_to_response('gcd/error.html',
          { 'error_text': 'You already have multiple accounts with this email '
                          'address.  Please contact an editor to get your '
                          'personal and/or shared accounts sorted out before '
                          'adding a new one.' },
          context_instance=RequestContext(request))
    user = users[0]
    if user.is_active:
        return render_to_response('gcd/error.html',
          { 'error_text': mark_safe(
            'You already have an active account with this email address.  If '
            'you have forgotten your password, you may <a href="' +
             urlresolvers.reverse('forgot_password') + '">reset '
            'it</a>.  If you feel you need a second account with this email, '
            'please '
            '<a href="mailto:gcd-contact@googlegroups.com">contact us</a>.') },
          context_instance=RequestContext(request))

    elif not user.indexer.is_banned:
        # TODO: automatic reactivation, but have to merge fields?  Complicated.
        return render_to_response('gcd/error.html',
          { 'error_text': mark_safe(
            'An account with this email address already exists, '
            'but is deactivated.  Please '
            '<a href="mailto:gcd-contact@googlegroups.com">contact us</a> '
            'if you would like to reactivate it.') },
          context_instance=RequestContext(request))
    else:
        return render_to_response('gcd/error.html',
          { 'error_text': 'A prior account with this email address has been '
                          'shut down.  Please contact an Editor if you believe '
                          'this was done in error.' },
          context_instance=RequestContext(request))

def profile(request, user_id=None, edit=False):
    if request.method == 'POST':
        return update_profile(request, user_id)

    if user_id is None:
        if request.user.is_authenticated():
            return HttpResponseRedirect(
              urlresolvers.reverse('view_profile',
                                   kwargs={'user_id': request.user.id}))
        else:
            return HttpResponseRedirect(
              urlresolvers.reverse('login'))
        profile_user = request.user
    else:
        profile_user = get_object_or_404(User, id=user_id)

    context = { 'profile_user': profile_user }
    if edit is True:
        if profile_user == request.user:
            form = ProfileForm(auto_id=True, initial={
              'email': profile_user.email,
              'given_name': profile_user.first_name,
              'family_name': profile_user.last_name,
              'country': profile_user.indexer.country.id,
              'languages':
                [ lang.id for lang in profile_user.indexer.languages.all() ],
              'interests': profile_user.indexer.interests,
            })
            context['form'] = form
        else:
            return render_to_response(
              'gcd/error.html',
              { 'error_text': "You may not edit other users' profiles" },
              context_instance=RequestContext(request))

    return render_to_response('gcd/accounts/profile.html',
                              context,
                              context_instance=RequestContext(request))

def update_profile(request, user_id=None):
    if request.user.id != int(user_id):
        # Should never get here, which of course means we will.
        # TODO: Should redirect, not render.
        return render_to_response(
          'gcd/error.html',
          { 'error_text' : 'You may only edit your own profile.' },
          context_instance=RequestContext(request))

    errors = []
    form = ProfileForm(request.POST)
    if not form.is_valid():
        return render_to_response('gcd/accounts/profile.html',
                                  { 'form': form },
                                  context_instance=RequestContext(request))
    set_password = False
    old = form.cleaned_data['old_password']
    new = form.cleaned_data['new_password']
    confirm = form.cleaned_data['confirm_new_password']
    if (new or confirm) and not old:
        errors.append(
          u'You must supply your old password in order to change it.')
    elif old and (new or confirm):
        if not request.user.check_password(old):
            errors.append(u'Old password incorrect, please try again.')
        elif new != confirm:
            errors.append(
              u'New password and confirm new password do not match.')
        else:
            set_password = True

    if errors:
        return render_to_response('gcd/accounts/profile.html',
                                  { 'form': form, 'error_list': errors },
                                  context_instance=RequestContext(request))

    request.user.first_name = form.cleaned_data['given_name']
    request.user.last_name = form.cleaned_data['family_name']
    request.user.email = form.cleaned_data['email']
    if set_password is True:
        request.user.set_password(new)
    request.user.save()

    indexer = request.user.indexer
    indexer.country = form.cleaned_data['country']
    indexer.languages = form.cleaned_data['languages']
    indexer.interests = form.cleaned_data['interests']
    indexer.save()

    return HttpResponseRedirect(
      urlresolvers.reverse('view_profile',
                           kwargs={'user_id': request.user.id}))

def mentor(request, indexer_id):
    return render_to_response(
          'gcd/error.html',
          { 'error_text' : 'This page is not yet written' },
          context_instance=RequestContext(request))

