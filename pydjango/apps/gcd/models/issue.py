# -*- coding: utf-8 -*-
from decimal import Decimal

from django.db import models
from django.core import urlresolvers
from django.db.models import Sum, Count
from django.contrib.contenttypes import generic
from django.contrib.contenttypes.models import ContentType

from taggit.managers import TaggableManager

from publisher import IndiciaPublisher, Brand
from series import Series
from image import Image

# TODO: should not be importing oi app into gcd app, dependency should be
# the other way around.  Probably.
from apps.oi import states

INDEXED = {
    'skeleton': 0,
    'full': 1,
    'partial': 2
}


class Issue(models.Model):
    class Meta:
        app_label = 'gcd'
        ordering = ['series', 'sort_code']

    # Issue identification
    number = models.CharField(max_length=50, db_index=True)
    title = models.CharField(max_length=255, db_index=True)
    no_title = models.BooleanField(default=False, db_index=True)
    volume = models.CharField(max_length=50, db_index=True)
    no_volume = models.BooleanField(default=False, db_index=True)
    display_volume_with_number = models.BooleanField(default=False, db_index=True)
    isbn = models.CharField(max_length=32, db_index=True)
    no_isbn = models.BooleanField(default=False, db_index=True)
    valid_isbn = models.CharField(max_length=13, db_index=True)
    variant_of = models.ForeignKey('self', null=True,
                                   related_name='variant_set')
    variant_name = models.CharField(max_length=255)
    barcode = models.CharField(max_length=38)
    no_barcode = models.BooleanField(default=False)

    # Dates and sorting
    publication_date = models.CharField(max_length=255)
    key_date = models.CharField(max_length=10)
    on_sale_date = models.CharField(max_length=10)
    on_sale_date_uncertain = models.BooleanField(blank=True)
    sort_code = models.IntegerField(db_index=True)
    indicia_frequency = models.CharField(max_length=255)
    no_indicia_frequency = models.BooleanField(default=False, db_index=True)

    # Price, page count and format fields
    price = models.CharField(max_length=255)
    page_count = models.DecimalField(max_digits=10, decimal_places=3, null=True)
    page_count_uncertain = models.BooleanField(default=False)

    editing = models.TextField()
    no_editing = models.BooleanField(default=False, db_index=True)
    notes = models.TextField()

    keywords = TaggableManager()
    
    # Series and publisher links
    series = models.ForeignKey(Series)
    indicia_publisher = models.ForeignKey(IndiciaPublisher, null=True)
    indicia_pub_not_printed = models.BooleanField(default=False)
    def _indicia_image(self):
        img = Image.objects.filter(object_id=self.id, deleted=False,
          content_type = ContentType.objects.get_for_model(self), type__id=1)
        if img:
            return img.get()
        else:
            return None
    indicia_image = property(_indicia_image)
    brand = models.ForeignKey(Brand, null=True)
    no_brand = models.BooleanField(default=False, db_index=True)

    def _soo_image(self):
        img = Image.objects.filter(object_id=self.id, deleted=False,
          content_type = ContentType.objects.get_for_model(self), type__id=2)
        if img:
            return img.get()
        else:
            return None
    soo_image = property(_soo_image)

    is_indexed = models.IntegerField(default=0, db_index=True)

    # Fields related to change management.
    reserved = models.BooleanField(default=False, db_index=True)

    created = models.DateTimeField(auto_now_add=True)
    modified = models.DateTimeField(auto_now=True, db_index=True)

    deleted = models.BooleanField(default=False, db_index=True)

    def active_stories(self):
        return self.story_set.exclude(deleted=True)

    def shown_stories(self):
        """ returns cover sequence and story sequences """
        if self.variant_of:
            stories_from = self.variant_of
        else:
            stories_from = self
        stories = list(stories_from.active_stories()
                                   .order_by('sequence_number')
                                   .select_related('type', 'migration_status'))
        if self.series.is_comics_publication:
            if (len(stories) > 0):
                cover_story = stories.pop(0)
                if self.variant_of:
                    # can have only one sequence, the variant cover
                    if self.active_stories().count():
                        cover_story = self.active_stories()[0]
            elif self.variant_of and len(list(self.active_stories())):
                cover_story = self.active_stories()[0]
            else:
                cover_story = None
        else:
            cover_story = None
        return cover_story, stories

    def active_covers(self):
        return self.cover_set.exclude(deleted=True)

    def variant_covers(self):
        """ returns the images from the variant issues """
        from cover import Cover
        if self.variant_of:
            variant_issues = list(self.variant_of.variant_set\
                                      .exclude(id=self.id)\
                                      .exclude(deleted=True)\
                                      .values_list('id', flat=True))
        else:
            variant_issues = list(self.variant_set.exclude(deleted=True)\
                                      .values_list('id', flat=True))
        variant_covers = Cover.objects.filter(issue__id__in=variant_issues)\
                                      .exclude(deleted=True)
        if self.variant_of:
            variant_covers |= self.variant_of.active_covers()
        return variant_covers

    def shown_covers(self):
        return self.active_covers(), self.variant_covers()

    def has_covers(self):
        return self.series.is_comics_publication and \
               self.active_covers().count() > 0

    def other_variants(self):
        if self.variant_of:
            variants = self.variant_of.variant_set.exclude(id=self.id)
        else:
            variants = self.variant_set.all()
        return list(variants.exclude(deleted=True))

    def _display_number(self):
        if self.title and self.series.has_issue_title:
            title = " - " + self.title
        else:
            title = ""
        if self.display_volume_with_number:
            return u'v%s#%s%s' % (self.volume, self.number, title)
        return self.number + title
    display_number = property(_display_number)

    # determine and set whether something has been indexed at all or not
    def set_indexed_status(self):
        from story import StoryType
        is_indexed = INDEXED['skeleton']
        if self.page_count > 0:
            total_count = self.active_stories()\
                              .aggregate(Sum('page_count'))['page_count__sum']
            if total_count > 0 and total_count >= Decimal('0.4') * self.page_count:
                is_indexed = INDEXED['full']
        if is_indexed != INDEXED['full'] and self.active_stories()\
          .filter(type=StoryType.objects.get(name='comic story')).count() > 0:
            is_indexed = INDEXED['partial']
            
        if self.is_indexed != is_indexed:
            self.is_indexed = is_indexed
            self.save()
        return self.is_indexed

    def index_status_name(self):
        """
        Text form of status.  If clauses arranged in order of most
        likely case to least.
        """
        if self.reserved:
            active =  self.revisions.get(changeset__state__in=states.ACTIVE)
            return states.CSS_NAME[active.changeset.state]
        elif self.is_indexed == INDEXED['full']:
            return 'approved'
        elif self.is_indexed == INDEXED['partial']:
            return 'partial'
        else:
            return 'available'

    def get_prev_next_issue(self):
        """
        Find the issues immediately before and after the given issue.
        """

        prev_issue = None
        next_issue = None

        earlier_issues = self.series.active_base_issues()\
                             .filter(sort_code__lt=self.sort_code)
        earlier_issues = earlier_issues.order_by('-sort_code')
        if earlier_issues:
            prev_issue = earlier_issues[0]

        later_issues = self.series.active_base_issues()\
                           .filter(sort_code__gt=self.sort_code)
        later_issues = later_issues.order_by('sort_code')
        if later_issues:
            next_issue = later_issues[0]

        return [prev_issue, next_issue]

    def delete(self):
        self.deleted = True
        self.reserved = False
        self.save()

    def has_reprints(self):
        from story import STORY_TYPES
        """Simplifies UI checks for conditionals.  notes and reprint fields"""
        return self.from_reprints.count() or \
               self.to_reprints.exclude(target__type__id=STORY_TYPES['promo']).count() or \
               self.from_issue_reprints.count() or \
               self.to_issue_reprints.count()

    def deletable(self):
        if self.cover_revisions.filter(changeset__state__in=states.ACTIVE)\
                                   .count() > 0:
            return False
        if self.variant_set.filter(deleted=False).count() > 0:
            return False
        if self.has_reprints():
            return False
        for story in self.active_stories():
            if story.has_reprints(notes=False):
                return False
        return True

    def can_upload_variants(self):
        if self.has_covers():
            return self.revisions.filter(changeset__state__in=states.ACTIVE,
                                         deleted=True).count() == 0
        else:
            return False

    def get_absolute_url(self):
        return urlresolvers.reverse(
            'show_issue',
            kwargs={'issue_id': self.id } )

    def full_name(self, variant_name=True):
        if variant_name and self.variant_name:
            return u'%s #%s [%s]' % (self.series.full_name(),
                                     self.display_number,
                                     self.variant_name)
        else:
            return u'%s #%s' % (self.series.full_name(), self.display_number)

    def short_name(self):
        if self.variant_name:
            return u'%s #%s [%s]' % (self.series.name,
                                     self.display_number,
                                     self.variant_name)
        else:
            return u'%s #%s' % (self.series.name, self.display_number)

    def __unicode__(self):
        if self.variant_name:
            return u'%s #%s [%s]' % (self.series, self.display_number,
                                     self.variant_name)
        else:
            return u'%s #%s' % (self.series, self.display_number)

