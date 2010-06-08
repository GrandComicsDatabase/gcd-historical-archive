from django.db import models

from publisher import IndiciaPublisher, Brand
from series import Series

# TODO: should not be importing oi app into gcd app, dependency should be
# the other way around.  Probably.
from apps.oi import states

class Issue(models.Model):
    class Meta:
        app_label = 'gcd'
        ordering = ['series', 'sort_code']

    # Issue identification
    number = models.CharField(max_length=25, db_index=True)
    volume = models.IntegerField(max_length=255, db_index=True, null=True)
    no_volume = models.BooleanField(default=0)
    display_volume_with_number = models.BooleanField(default=False)

    # Dates and sorting
    publication_date = models.CharField(max_length=255)
    key_date = models.CharField(max_length=10)
    sort_code = models.IntegerField(db_index=True)
    indicia_frequency = models.CharField(max_length=255)

    # Price, page count and format fields
    price = models.CharField(max_length=255)
    page_count = models.DecimalField(max_digits=10, decimal_places=3, null=True)
    page_count_uncertain = models.BooleanField(default=0)

    editing = models.TextField()
    no_editing = models.BooleanField(default=0)
    notes = models.TextField()

    # Fields related to indexing activities.
    # Only "reserved" is in active use, the others are legacy fields
    # used only by migration scripts.
    reserved = models.BooleanField(default=0, db_index=True)
    index_status = models.IntegerField(default=0, null=True)
    reserve_status = models.IntegerField(default=0, db_index=True)
    reserve_check = models.NullBooleanField(default=0, db_index=True)

    # Series and publisher links
    series = models.ForeignKey(Series)
    indicia_publisher = models.ForeignKey(IndiciaPublisher, null=True)
    indicia_pub_not_printed = models.BooleanField(default=0)
    brand = models.ForeignKey(Brand, null=True)
    no_brand = models.BooleanField(default=0, db_index=True)

    # Count of stories of type "story" attached to this issue.
    # Used to determine whether something has been indexed at all or not.
    story_type_count = models.IntegerField(default=0, db_index=True)

    # Fields related to change management.
    created = models.DateTimeField(auto_now_add=True)
    modified = models.DateTimeField(auto_now=True, db_index=True)

    def active_stories(self):
        return self.story_set.exclude(deleted=True)
    
    def _display_number(self):
        if self.display_volume_with_number:
            return u'v%s#%s' % (self.volume, self.number)
        return self.number
    display_number = property(_display_number)

    def index_status_name(self):
        """
        Text form of status.  If clauses arranged in order of most
        likely case to least.
        """
        if self.reserved:
            active =  self.revisions.get(changeset__state__in=states.ACTIVE)
            return states.CSS_NAME[active.changeset.state]
        else:
            if self.story_type_count > 0:
                return 'approved'
            return 'available'

    def get_prev_next_issue(self):
        """
        Find the issues immediately before and after the given issue.
        """

        prev_issue = None
        next_issue = None

        earlier_issues = \
          self.series.issue_set.filter(sort_code__lt=self.sort_code)
        earlier_issues = earlier_issues.order_by('-sort_code')
        if earlier_issues:
            prev_issue = earlier_issues[0]     
        
        later_issues = self.series.issue_set.filter(sort_code__gt=self.sort_code)
        later_issues = later_issues.order_by('sort_code')
        if later_issues:
            next_issue = later_issues[0]

        return [prev_issue, next_issue]

    def reserver(self):
        """
        Return the likely current reservation holder.  While it is common
        for an issue to have multiple reservation records for the same issue
        in the same status, at no point in the current (at this time) data set
        does an issue have more than one unapproved reservation record with
        differen indexers in each.  So taking the first 
        """
        if self.index_status in (1, 2):
            reservers = self.reservation_set.filter(status=self.index_status)
            if reservers.count() > 0:
                return reservers[0].indexer
        return None

    def get_absolute_url(self):
        return "/issue/%i/" % self.id

    def __unicode__(self):
        return u'%s #%s' % (self.series, self.display_number)

