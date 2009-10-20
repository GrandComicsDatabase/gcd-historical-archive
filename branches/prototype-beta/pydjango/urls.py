from django.conf.urls.defaults import *
from django.conf import settings
from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.views.generic.simple import direct_to_template

urlpatterns = patterns('',
    (r'^admin/', include(admin.site.urls)),

    # Account management

    # Logout will only look for a 'next_page' parameter in GET, but
    # GET requests should not have side effects so use a wrapper to
    # pull from POST.
    url(r'^accounts/logout/$',
        lambda request: auth_views.logout(request,
                                          next_page=request.POST['next']),
        name='gcd_logout'),
    (r'^accounts/login/$', auth_views.login, 
     {'template_name': 'gcd/accounts/login.html'}),
    (r'^accounts/profile/$', 'apps.gcd.views.accounts.profile'),
    url(r'^accounts/forgot/$',
        direct_to_template,
        { 'template': 'gcd/accounts/forgot.html' },
        name='forgot_password'),
    url(r'^donate/$', direct_to_template, { 'template': 'gcd/donate/donate.html' }, name='donate'),
    url(r'^donate/thanks/$', direct_to_template, { 'template': 'gcd/donate/thanks.html' }, name='donate_thanks'),

    (r'^', include('apps.gcd.urls')),
    # (r'^', include('apps.oi.urls')),
    # (r'^inducks/', include('apps.inducks.urls')),
)

if settings.DEBUG:
    urlpatterns += patterns('',
        (r'site_media/(?P<path>.*)$', 'django.views.static.serve',
         { 'document_root' : settings.MEDIA_ROOT }))
