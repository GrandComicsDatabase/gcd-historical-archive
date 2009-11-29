from django.db import models
from country import Country
from django.core.exceptions import ObjectDoesNotExist

class BasePublisher(models.Model):
    class Meta:
        abstract = True

    # Core publisher fields.
    name = models.CharField(max_length=255, db_index=True)
    year_began = models.IntegerField(db_index=True, null=True)
    year_ended = models.IntegerField(null=True)
    notes = models.TextField()
    url = models.URLField()

    # Fields related to change management.
    reserved = models.BooleanField(default=0, db_index=True)
    created = models.DateField(auto_now_add=True)
    modified = models.DateField(auto_now=True)

    def __unicode__(self):
        return self.name

class Publisher(BasePublisher):
    class Meta:
        ordering = ['name']
        app_label = 'gcd'

    country = models.ForeignKey(Country)

    # Cached counts.
    imprint_count = models.IntegerField(default=0)
    brand_count = models.IntegerField(default=0)
    indicia_publisher_count = models.IntegerField(default=0)
    series_count = models.IntegerField(default=0)
    issue_count = models.IntegerField(default=0)

    # Fields about relating publishers/imprints to each other.
    is_master = models.BooleanField(db_index=True)
    parent = models.ForeignKey('self', null=True,
                               related_name='imprint_set')

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
        """
        TODO: This needs to be retired now that the data has been cleaned up.
        If we want to ensure '' instead of None we should set the db column
        to NOT NULL default ''.
        """
        if self.url is None:
            return ''
        return self.url

    def get_full_name(self):
        if self.is_imprint():
            if self.parent_id:
                return '%s: %s' % (self.parent.name, self.name)
            return '*GCD ORPHAN IMPRINT: %s' % (self.name)
        return self.name

    # TODO: Should be able to remove this.  Verify we're not using it anywhere.
    def computed_issue_count(self):
        # issue_count is not accurate, but computing is slow.
        return self.issue_count or 0

        # This is more accurate, but too slow right now.
        # Would be better to properly maintain issue_count.
        # num_issues = 0
        # for series in self.series_set.all():
        #     num_issues += series.issue_set.count()
        # return num_issues

class IndiciaPublisher(BasePublisher):
    class Meta:
        db_table = 'gcd_indicia_publisher'
        ordering = ['name']
        app_label = 'gcd'

    parent = models.ForeignKey(Publisher, related_name='indicia_publishers')
    is_surrogate = models.BooleanField(db_index=True)
    country = models.ForeignKey(Country)

    def get_absolute_url(self):
        return "/indicia_publisher/%i/" % self.id

    def __unicode__(self):
        return self.name

class Brand(BasePublisher):
    class Meta:
        ordering = ['name']
        app_label = 'gcd'

    parent = models.ForeignKey(Publisher, related_name='brands')

    def get_absolute_url(self):
        return "/brand/%i/" % self.id

    def __unicode__(self):
        return self.name

