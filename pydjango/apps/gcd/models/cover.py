# -*- coding: utf-8 -*-
from django.db import models
from django.core import urlresolvers

from issue import Issue
from series import Series

class Cover(models.Model):
    class Meta:
        app_label = 'gcd'
        ordering = ['issue']
        get_latest_by = "id"
        permissions = (
            ('can_upload_cover', 'can upload cover'),
        )

    # The issue field should be considered the primary link.  Series is legacy.
    series = models.ForeignKey(Series)
    issue = models.ForeignKey(Issue)

    # Fields directly related to cover images
    #code = models.CharField(max_length=50)
    has_image = models.BooleanField()
    marked = models.BooleanField(default=0)

    server_version = models.IntegerField()
    contributor = models.CharField(max_length=255, null=True)
    file_extension = models.CharField(max_length = 10)
    variant_code = models.CharField(max_length = 2, null = True)

    # Fields related to change management.
    created = models.DateTimeField(auto_now_add=True, null=True)
    modified = models.DateTimeField(null=True)

    def get_status_url(self):
        if self.marked or not self.has_image:
            return urlresolvers.reverse(
                'apps.gcd.views.covers.cover_upload',
                kwargs={'cover_id': self.id} )
        else:
            return self.issue.get_absolute_url()

    def get_cover_status(self):
        import logging
        if self.marked:
            return 4
        if self.has_image:
            return 3
        return 0

