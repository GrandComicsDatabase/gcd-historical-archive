from django.contrib import admin
from django import forms
from gcd.migration.models import *


class SequenceStatusAdmin(admin.ModelAdmin):
    search_fields = ['sequence__series_name', '=sequence__issue_number']
    raw_id_fields = ('sequence',)

admin.site.register(SequenceStatus, SequenceStatusAdmin)

