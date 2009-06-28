from django.conf.urls.defaults import *
from django.conf import settings
from django.contrib import admin
from django.views.generic import list_detail

from gcd.core.models import MasterPublisher

admin.autodiscover()

publisher_list_info = {
    'queryset': MasterPublisher.objects,
    'paginate_by': 100,
    'template_object_name': 'publisher',
}

urlpatterns = patterns('',
    # Example:

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    (r'^admin/', include(admin.site.urls)),
    (r'site_media/(?P<path>.*)$', 'django.views.static.serve',
     { 'document_root' : settings.MEDIA_ROOT }),
    (r'^publishers/', list_detail.object_list, publisher_list_info),
    (r'^.*/', 'gcd.core.views.oops'),
)

# if settings.DEBUG:
#     urlpatterns += patterns('',
#         (r'site_media/(?P<path>.*)$', 'django.views.static.serve',
#          { 'document_root' : settings.MEDIA_ROOT }))

