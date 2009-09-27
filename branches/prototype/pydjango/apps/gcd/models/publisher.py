from django.db import models
from country import Country
from django.core.exceptions import ObjectDoesNotExist

class Publisher(models.Model):
    class Meta:
        db_table = 'publishers'
        ordering = ['name']
        app_label = 'gcd'

    id = models.AutoField(primary_key=True, db_column='ID')

    # Core publisher fields.
    name = models.CharField(max_length=255, db_column='PubName', null=True)
    year_began = models.IntegerField(db_column='YearBegan', null=True)
    year_ended = models.IntegerField(db_column='YearEnded', null=True)
    country = models.ForeignKey(Country, db_column='CountryID', null=True)
    notes = models.TextField(db_column='Notes', null=True)
    url = models.URLField(db_column='web', null=True)

    # Cached counts.  Not guaranteed to be accurate in a production dump.
    imprint_count = models.IntegerField(db_column='ImprintCount', null=True)
    series_count = models.IntegerField(db_column='BookCount', null=True)
    issue_count = models.IntegerField(db_column='IssueCount', null=True)

    # Fields about relating publishers/imprints to each other.
    is_master = models.NullBooleanField(db_column='Master')
    parent = models.ForeignKey('self', db_column='ParentID',
                               null=True, related_name='imprint_set')

    # Fields related to change management.
    reserved = models.BooleanField(default=0, db_index=True)
    created = models.DateField(auto_now_add=True, null=True)
    modified = models.DateField(db_column='Modified', auto_now=True, null=True)

    def __unicode__(self):
        return self.name

    def has_imprints(self):
        return self.imprint_set.count() > 0

    def is_imprint(self):
        return self.parent_id is not None and self.parent_id != 0

    def get_absolute_url(self):
        if self.is_imprint():
            return "/imprint/%i/" % self.id
        else:
            return "/publisher/%i/" % self.id

    def get_official_url(self):
        try:
            if not self.url.lower().startswith("http://"):
                self.url = "http://" + self.url
                #TODO: auto fix urls ?
                #self.save()
        except:
            return ""

        return self.url

    def __unicode__(self):
        if self.is_imprint():
            if self.parent_id:
                return '%s: %s' % (self.parent.name, self.name)
            return '*GCD ORPHAN IMPRINT: %s' % (self.name)
        return self.name

    def computed_issue_count(self):
        # issue_count is not accurate, but computing is slow.
        return self.issue_count or 0

        # This is more accurate, but too slow right now.
        # Would be better to properly maintain issue_count.
        # num_issues = 0
        # for series in self.series_set.all():
        #     num_issues += series.issue_set.count()
        # return num_issues

