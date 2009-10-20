# -*- coding: utf-8 -*-
from django.core import urlresolvers
from django.conf import settings
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User, Group

from apps.gcd.models import Indexer, Language, Country
from apps.gcd.forms.accounts import ProfileForm, RegistrationForm
from apps.gcd.mail import send_email, email_editors

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

    new_user = User.objects.create_user(cd['username'],
                                        cd['email'],
                                        cd['password'])
    new_user.first_name = cd['given_name']
    new_user.last_name = cd['family_name']
    new_user.save()

    new_user.groups.add(*Group.objects.filter(name='indexer'))

    indexer = Indexer(is_new=True,
                      max_reservations=1,
                      max_ongoing=0,
                      country=cd['country'],
                      interests=cd['interests'],
                      user=new_user)
    indexer.save()

    if cd['languages']:
        indexer.languages.add(*cd['languages'])

    # We disply a logout page instead of the registration form
    # if the user is logged in, so we *should* be able to rely
    # on there being no logged in user at this point.
    if request.user.is_authenticated():
        return render_to_response(
          'gcd/error.html',
          { 'error_text': 'Registration successful but you were already '
                          'logged in as another user.  You may want to '
                          'log out and log in again as the new user.' },
          context_instance=RequestContext(request))

    if cd['given_name'] and cd['family_name']:
        full_name = '%s %s' % (cd['given_name'], cd['family_name'])
    elif cd['given_name']:
        full_name = cd['given_name']
    else:
        full_name = cd['family_name']

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
    """ % (new_user.username,
           full_name,
           new_user.email,
           indexer.country.name,
           ', '.join([lang.name for lang in indexer.languages.all()]),
           indexer.interests,
           'http://' + request.get_host() +
           urlresolvers.reverse('mentor', kwargs={ 'indexer_id': indexer.id }))

    email_editors(from_addr=settings.EMAIL_NEW_ACCOUNTS_FROM,
                  subject='New Indexer: %s' % full_name,
                  body=email_body)
    authenticated_user = authenticate(username=cd['username'],
                                      password=cd['password'])
    if authenticated_user is None:
        return render_to_response(
          'gcd/error.html',
          { 'error_text': 'Could not log in new user.  If you cannot log in '
                          'using the button in the search bar at the top of '
                          'the page, please '
                          '<a href="mailto:gcd-contact@googlegroups.com">email '
                          'us</a> with your attempted username.' },
          context_instance=RequestContext(request))
    login(request, authenticated_user)

    return HttpResponseRedirect(urlresolvers.reverse('welcome'))


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
              urlresolvers.reverse('django.contrib.auth.views.login'))
        profile_user = request.user
    else:
        profile_user = get_object_or_404(User, id=user_id)

    context = { 'profile_user': profile_user }
    if edit is True:
        if profile_user == request.user:
            form = ProfileForm(auto_id=True, initial={
              'username': profile_user.username,
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

    # TODO: Much duplicaton with the register view in the form validation.
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

