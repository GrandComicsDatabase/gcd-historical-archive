import re

from django import forms
from django.forms.util import ErrorList
from django.contrib.auth.models import User

from apps.gcd.models import Indexer, Country, Language

class AccountForm(forms.Form):
    email = forms.EmailField(max_length=75)
    
    given_name = forms.CharField(max_length=30,
                                 required=False)
    family_name = forms.CharField(max_length=30,
                                  required=False)
    country = forms.ModelChoiceField(
        queryset=Country.objects.exclude(name='-- FIX ME --').order_by('name'),
        empty_label='--- Please Select a Country ---')

    languages = forms.ModelMultipleChoiceField(
        queryset=Language.objects.exclude(code='zxx').order_by('name'),
        required=False,
        widget=forms.SelectMultiple(attrs={'size' : '6'}))

    interests = forms.CharField(widget=forms.Textarea, required=False)

    def clean(self):
        cd = self.cleaned_data
        if ('given_name' in cd and 'family_name' in cd and
            not cd['given_name'] and not cd['family_name']):
            error_msg = (
              'Please fill in either family name or given name, or '
              'both. You may use an alias if you do not wish your '
              'real name to appear on the site.')
            self._errors['given_name'] = ErrorList([error_msg])
            self._errors['family_name'] = ErrorList([error_msg])
        return cd

class RegistrationForm(AccountForm):
    username = forms.RegexField(regex=re.compile(r'^(?!_)[\w.]+$', re.UNICODE),
                                max_length=30,
                                error_messages={
                                  'invalid': 'Usernames may only contain '
                                             'letters (in any language), '
                                             'numbers and underscores ("_"), '
                                             'and may not start with an '
                                             'underscore.'
                                })
    password = forms.CharField(widget=forms.PasswordInput,
                               min_length=6,
                               max_length=128)
    confirm_password = forms.CharField(widget=forms.PasswordInput,
                                       min_length=6,
                                       max_length=128)
    def clean(self):
        AccountForm.clean(self)

        cd = self.cleaned_data
        if ('username' in cd and
            User.objects.filter(username=cd['username']).count()):
            self._errors['username'] = ErrorList(
              ['Username "%s" is already in use.' % cd['username']])
            del cd['username']

        if ('password' in cd and 'confirm_password' in cd and
            cd['password'] != cd['confirm_password']):
            self._errors['password'] = ErrorList(
              ['Password and confirm password do not match.'])
            del cd['password']
            del cd['confirm_password']

        return cd

class ProfileForm(AccountForm):
    old_password = forms.CharField(widget=forms.PasswordInput,
                                   min_length=6,
                                   max_length=128,
                                   required=False)
    new_password = forms.CharField(widget=forms.PasswordInput,
                                   min_length=6,
                                   max_length=128,
                                   required=False)
    confirm_new_password = forms.CharField(widget=forms.PasswordInput,
                                           min_length=6,
                                           max_length=128,
                                           required=False)

    def clean(self):
        AccountForm.clean(self)

        cd = self.cleaned_data
        return cd

        set_password = False
        if ('old_password' not in cd or 'new_password' not in cd or
            'confirm_new_password' not in cd):
            return cd

        old = cd['old_password']
        new = cd['new_password']
        confirm = cd['confirm_new_password']
        if (new or confirm) and not old:
            self._errors['old_password'] = ErrorList(
              ['You must supply your old password in order to change it.'])
            cd = self._del_passwords(cd)

        elif old and (new or confirm):
            if not request.user.check_password(old):
                self._errors['old_password'] = ErrorList(
                  ['Old password incorrect, please try again.'])
                cd = self._del_passwords(cd)
            elif new != confirm:
                self._errors['new_password'] = ErrorList(
                  ['New password and confirm new password do not match.'])
                cd = self._del_passwords(cd)

        return cd

    def _del_passwords(self, cd):
        del cd['old_password']
        del cd['new_password']
        del cd['confirm_new_password']
        return cd