from django.contrib import admin
from django import forms
from gcd.core.models import *

class SequenceInline(admin.StackedInline):
    model = Sequence
    extra = 1
    fieldsets = (
      ('Basics', { 'classes': ('collapse',), 'fields':
        ('number',
         'title',
         'feature',
         'type',
         'page_count',
         'job_number',) } ),
      ('Credits', { 'classes': ('collapse', 'brief'), 'fields':
        ('script', 'pencils', 'inks', 'colors', 'letters', 'editing') } ),
      ('Content', { 'classes': ('collapse',),
                    'fields': ('genre', 'characters', 'synopsis') } ),
      ('Notes', { 'classes': ('collapse',), 'fields': ('reprint_notes',
                                                       'notes') } ),
    )

class ImprintAdmin(admin.ModelAdmin):
    """
    In order to be used from the Series page (to hook to an imprint),
    Imprints must have a top-level admin object, not just an inline.
    Ideally this would not actually show up in the main list.
    """

    search_fields = ['name']
    raw_id_fields = ('parent',)
    fieldsets = (
      (None, { 'fields': ('name', 'master', 'parent', 'year_began',
                          'year_ended', 'country', 'notes', 'url') }
      ),
    )
 
class ImprintInline(admin.StackedInline):
    model = Imprint
    fk_name = "parent"
    extra = 1
    fieldsets = (
      ('Fields', { 'classes': ('collapse',),
                   'fields': ('name', 'master', 'year_began',
                              'year_ended', 'country', 'notes', 'url') }
      ),
    )
 
class MasterPublisherAdmin(admin.ModelAdmin):
    search_fields = ['name']
    fieldsets = (
      (None, { 'fields': ('name', 'master', 'year_began',
                          'year_ended', 'country', 'notes', 'url') }
      ),
    )
    inlines = [ImprintInline]

class SeriesAdmin(admin.ModelAdmin):
    search_fields = ['name']
    list_filter = ('country_code', 'language_code')
    display_list = ('name', 'publisher_name', 'year_began', 'issue_count')
    raw_id_fields = ('publisher', 'imprint')
    fieldsets = (
      (None, { 'fields': ('name', 'publisher', 'imprint',
                          'country_code', 'language_code',
                          'format', 'year_began', 'year_ended',
                          'publication_dates') }
      ),
      ('Notes', { 'fields': ('publication_notes',
                             'tracking_notes', 'notes') }
      ),
    )

class CoverInline(admin.StackedInline):
    model = Cover
    extra = 1
    raw_id_fields = ('series', 'issue')
    fieldsets = (
      (None, {'fields': ('sequence_number',
                         'marked') } ),
      ('Images', {'fields': ('has_image', 'contributor', 'has_small',
                             'has_medium', 'has_large', 'server_version'),
                  'classes': ('collapse',) } ),
    )

class IssueAdmin(admin.ModelAdmin):
    search_fields = ['series_name', '=number']
    raw_id_fields = ('series',)
    fieldsets = (
      (None, { 'fields': ('series', 'number', 'volume', 'key_date',
                          'publication_date',
                          'price', 'page_count', 'editing', 'notes') }
      ),
    )
    inlines = [SequenceInline, CoverInline]

class IndexerAdmin(admin.ModelAdmin):
    search_fields = ['family_name', 'given_name']
    list_display = ('family_name', 'given_name')

admin.site.register(Country)
admin.site.register(Language)
admin.site.register(Indexer, IndexerAdmin)
admin.site.register(Imprint, ImprintAdmin)
admin.site.register(MasterPublisher, MasterPublisherAdmin)
admin.site.register(Series, SeriesAdmin)
admin.site.register(Issue, IssueAdmin)

