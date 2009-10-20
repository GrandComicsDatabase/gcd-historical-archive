# -*- coding: utf-8 -*-
from django.db import models
from django.contrib.auth.models import User

from apps.gcd.models import Country, Language

class Indexer(models.Model):
    """ indexer from gcd database"""

    class Meta:
        db_table = 'Indexers'
        app_label = 'gcd'
        ordering = ['user__last_name', 'user__first_name']

    class Admin:
        pass

    id = models.AutoField(primary_key=True, db_column='ID')

    user = models.OneToOneField(User)

    country = models.ForeignKey(Country, related_name='indexers')
    languages = models.ManyToManyField(Language, related_name='indexers')
    interests = models.TextField(null=True, blank=True)

    max_reservations = models.IntegerField()
    max_ongoing = models.IntegerField()

    mentor = models.ForeignKey('self', related_name='mentees')
    is_new = models.BooleanField()
    deceased = models.BooleanField()

    def __unicode__(self):
        return unicode(self.user)

