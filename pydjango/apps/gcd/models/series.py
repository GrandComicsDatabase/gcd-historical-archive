# -*- coding: utf-8 -*-
from django.db import models

from apps.gcd.models.country import Country
from apps.gcd.models.language import Language
from apps.gcd.models.publisher import Publisher

class Series(models.Model):
    class Meta:
        app_label = 'gcd'
        ordering = ['name', 'year_began']
    
    # Core series fields.
    name = models.CharField(max_length=255, db_index=True)
    format = models.CharField(max_length=255)
    notes = models.TextField()

    year_began = models.IntegerField(db_index=True)
    year_ended = models.IntegerField(null=True)
    is_current = models.BooleanField()
    publication_dates = models.CharField(max_length=255)

    first_issue = models.ForeignKey('Issue', null=True,
      related_name='first_issue_series_set')
    last_issue = models.ForeignKey('Issue', null=True,
      related_name='last_issue_series_set')
    issue_count = models.IntegerField()

    # Publication notes are not displayed in the current UI but may
    # be accessed in the OI.
    publication_notes = models.TextField()

    # Fields for tracking relationships between series.
    # Crossref fields don't appear to really be used- nearly all null.
    tracking_notes = models.TextField()

    # Fields related to cover image galleries.
    has_gallery = models.BooleanField(db_index=True)

    # Fields related to indexing activities.
    # Only "reserved" is in active use.  "open_reserve" is a legacy field
    # used only by migration scripts.
    reserved = models.BooleanField(default=0, db_index=True)
    open_reserve = models.IntegerField(null=True)

    # Country and Language info.
    country = models.ForeignKey(Country)
    language = models.ForeignKey(Language)

    # Fields related to the publishers table.
    publisher = models.ForeignKey(Publisher, null=True)
    imprint = models.ForeignKey(Publisher, null=True,
                                related_name='imprint_series_set')

    # Fields related to change management.
    created = models.DateTimeField(auto_now_add=True)
    modified = models.DateTimeField(auto_now=True)

    def get_absolute_url(self):
        return "/series/%i/" % self.id

    def marked_scan_count(self):
        return self.cover_set.filter(marked=True, has_image='1').count()

    def scan_count(self):
        return self.cover_set.filter(has_image='1').count()

    def scan_needed(self):
        return self.issue_count - self.scan_count() + self.marked_scan_count()

    def __unicode__(self):
        return '%s (%s series)' % (self.name, self.year_began)

