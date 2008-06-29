from django.conf.urls.defaults import *
from django.conf import settings

urlpatterns = patterns('',
    # Example:
    # (r'^gcd/', include('gcd.foo.urls')),

    # Uncomment this for admin:
    (r'^admin/', include('django.contrib.admin.urls')),

    ###########################################################################
    # GCD URLs.
    #
    # General forms, where <entity> is publisher, series or issue and
    # <credit> is writer, penciller, etc.:
    #   gcd/<entity>/<id>/ shows details for the given entity.
    #   gcd/<entity>/name/<name> searches for entities by name.
    #   gcd/<credit>/name/<name> searches for stories by the named credit.
    #
    # In many cases a suffix of /sort/<sort type>/ is an optional extension.
    # In such cases, the form specifying the sort type must be listed first
    # or else it will never be used because the shorter form will always match.
    ###########################################################################

    (r'^gcd/$', 'apps.gcd.views.index'),
    (r'^gcd/search/$', 'apps.gcd.views.search.search'),
    (r'^gcd/search/advanced/$', 'apps.gcd.views.search.advanced_search'),

    # Publisher
    (r'^gcd/publisher/(?P<publisher_id>\d+)/$',
     'apps.gcd.views.details.publisher'),
    (r'^gcd/publisher/name/(?P<publisher_name>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.publishers_by_name'),
    (r'^gcd/publisher/name/(?P<publisher_name>.+)/$',
     'apps.gcd.views.search.publishers_by_name'),
    (r'^gcd/publisher/(?P<publisher_id>\d+)/imprints/$',
     'apps.gcd.views.details.imprints'),

    # Series
    (r'^gcd/series/(?P<series_id>\d+)/$', 'apps.gcd.views.details.series'),
    (r'^gcd/series/name/(?P<series_name>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.series_by_name'),
    (r'^gcd/series/name/(?P<series_name>.+)/$',
     'apps.gcd.views.search.series_by_name'),

    # Series index and cover status / gallery
    (r'^gcd/series/(?P<series_id>\d+)/status/$',
     'apps.gcd.views.details.status'),

    (r'^gcd/series/(?P<series_id>\d+)/covers/$',
     'apps.gcd.views.details.covers'),

    (r'^gcd/series/(?P<series_id>\d+)/scans/$',
     'apps.gcd.views.details.scans'),

    # Issue
    (r'^gcd/issue/(?P<issue_id>\d+)/$', 'apps.gcd.views.details.issue'),
    (r'^gcd/issue/$', 'apps.gcd.views.details.issue_form'),

    # Single Cover
    (r'^gcd/issue/(?P<issue_id>\d+)/cover/(?P<size>\d+)/$',
     'apps.gcd.views.details.cover'),

    # Attribute searches
    (r'^gcd/character/name/(?P<character_name>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.character_appearances'),
    (r'^gcd/character/name/(?P<character_name>.+)/$',
     'apps.gcd.views.search.character_appearances'),

    (r'^gcd/writer/name/(?P<writer>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.writer_by_name'),
    (r'^gcd/writer/name/(?P<writer>.+)/$',
     'apps.gcd.views.search.writer_by_name'),

    (r'^gcd/penciller/name/(?P<penciller>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.penciller_by_name'),
    (r'^gcd/penciller/name/(?P<penciller>.+)/$',
     'apps.gcd.views.search.penciller_by_name'),

    (r'^gcd/inker/name/(?P<inker>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.inker_by_name'),
    (r'^gcd/inker/name/(?P<inker>.+)/$',
     'apps.gcd.views.search.inker_by_name'),

    (r'^gcd/colorist/name/(?P<colorist>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.colorist_by_name'),
    (r'^gcd/colorist/name/(?P<colorist>.+)/$',
     'apps.gcd.views.search.colorist_by_name'),

    (r'^gcd/letterer/name/(?P<letterer>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.letterer_by_name'),
    (r'^gcd/letterer/name/(?P<letterer>.+)/$',
     'apps.gcd.views.search.letterer_by_name'),

    (r'^gcd/editor/name/(?P<editor>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.editor_by_name'),
    (r'^gcd/editor/name/(?P<editor>.+)/$',
     'apps.gcd.views.search.editor_by_name'),

    (r'^gcd/story/name/(?P<title>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.story_by_title'),
    (r'^gcd/story/name/(?P<title>.+)/$',
     'apps.gcd.views.search.story_by_title'),

    (r'^gcd/credit/name/(?P<name>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.story_by_credit'),
    (r'^gcd/credit/name/(?P<name>.+)/$',
     'apps.gcd.views.search.story_by_credit'),

    # Note that Jobs don't have 'name' in the path, but otherwise work the same.
    (r'^gcd/job/(?P<number>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.story_by_job'),
    (r'^gcd/job/(?P<number>.+)/$', 'apps.gcd.views.search.story_by_job'),

    # Reprints
    (r'^gcd/reprint/(?P<reprints>.+)/sort/(?P<sort>.+)/$',
     'apps.gcd.views.search.story_by_reprint'),
    (r'^gcd/reprint/(?P<reprints>.+)/$',
     'apps.gcd.views.search.story_by_reprint'),
    (r'^gcd/settings/$',
     'apps.gcd.views.settings.settings'),    

    # URL for trying out new layouts, styles and UI concepts.
    (r'^gcd/new/(?P<name>.+)/$', 'apps.gcd.views.prototype'),
)
