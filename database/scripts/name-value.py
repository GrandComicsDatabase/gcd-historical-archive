"""
This script produces an issue-centric name-value pair export of the database.
This format is useful for some clients of GCD data, but is not intended to
be a general-purpose format.  It folds some data from series, publishers, etc.
into the issue-centric view, and results in story-specific data fields simply
appearing mutliple times per issue with different values and no indication of
which field values are grouped on a particular story.

The GCD django app must be in PYTHONPATH for this to work.
"""

import sys
import logging
from django.db import connection, models
from apps.gcd.models import *

# TODO: When we move up to Python 2.6 (or even 2.5) these related name access
# functions can all be replaced by the "x if foo else y" construct in a lambda.

def _brand_name(issue):
    if issue.brand:
        return issue.brand.name
    return u''

def _indicia_publisher_name(issue):
    if issue.indicia_publisher:
        return issue.indicia_publisher.name
    return u''

def _page_count(issue):
    if issue.page_count is None:
        return u''
    return u'%d' % issue.page_count


# Map moderately human-friendly field names to functions producing the data from
# an issue record.
ISSUE_FIELDS = {'series name': lambda i: i.series.name or u'',
                'issue number': lambda i: i.number,
                'volume': lambda i: i.volume,
                'no volume': lambda i: i.no_volume,
                'display number': lambda i: i.display_number,
                'price': lambda i: i.price or u'',
                'issue page count': _page_count,
                'issue page count uncertain': lambda i: i.page_count_uncertain,
                'publication date': lambda i: i.publication_date or u'',
                'key date': lambda i: i.key_date or u'',
                'publisher name': lambda i: i.series.publisher.name,
                'brand name': _brand_name,
                'indicia publisher name': _indicia_publisher_name,
                'format': lambda i: i.series.format,
                'language code': lambda i: i.series.language.code,
                'series country code': lambda i: i.series.country.code,
                'publisher country code': lambda i: i.series.publisher.country.code}

    
# Map moderately human-friendly field names to functions producing the data from
# a story record.
STORY_FIELDS = {'title': lambda s: s.title,
                'title by gcd': lambda s: s.title_inferred,
                'feature': lambda s: s.feature,
                'script': lambda s: s.script,
                'pencils': lambda s: s.pencils,
                'inks': lambda s: s.inks,
                'genre': lambda s: s.genre,
                'type': lambda s: s.type.name}

# The story types to include in the data.  This is intended to pick up various
# sorts of illustrations that may provide an interesting art credit.
# "filler" is included due to it being used very inconsistently, sometimes for
# two or larger page stories, sometimes for up to half of an issue.
# Character profiles are included as our data includes some comics that contain
# nothing but character profiles.
STORY_TYPES = ('story',
               'photo story',
               'cover',
               'cover reprint',
               'cartoon',
               'illustration',
               'filler',
               'character profile')

DELTA = 10000

def _next_range(old_end, max):
    """
    This manages pushing the query window along for the large queries that
    need to be done in chunks to keep from using too much memory.
    """
    if old_end == max:
        return None, None

    end = old_end + DELTA
    if max < end:
        end = max

    # The django range operator (SQL BETWEEN) is inclusive, don't double up
    # on the old end value.
    return old_end + 1, end

def _fix_value(value):
    """
    NULL and empty string values should not be present in the output at all,
    so ensure that both are flagged as None.  Supply consistent quotes for
    everything else.
    """
    if value is None or value == u'':
        return None
    return u'"' + value + u'"'

def _dump_table(dumpfile, objects, max, fields, get_id):
    """
    Dump records from a table a chunk at a time, selecting particular fields.
    Fields with a NULL or empty string value are omitted.
    """
    start = 0
    end = start + DELTA
    had_error = False
    while start is not None:
        logging.info("Dumping object rows %d through %d (out of %d)" %
                     (start, end, max))
        try:
            for object in objects.filter(id__range=(start, end)).iterator():
                for name, func in fields.items():
                    value = unicode(func(object)).replace(u'"', u'""')
                    value = _fix_value(value)
                    if value is not None:
                        record = u'"%d"\t"%s"\t%s\n' % (get_id(object), name, value)
                        dumpfile.write(record.encode('utf-8'))
        except IndexError:
            # Somehow our count was wrong and we ran off the end.  That's OK
            # because it just means we tried to select extra rows that aren't there.
            # Unless we're seeing it again, in which case our code is in error and
            # we'll probably be stuck in a loop if we don't let this go.
            if had_error:
                raise
            had_error = True

        start, end = _next_range(end, max)

def main():
    """
    Dump public data in chunks, manually establishing a transaction to ensure
    a consistent view.  The BEGIN statement must be issued manually because
    django transation objects will only initiate a transaction when writes
    are involved.
    """

    logging.basicConfig(level=logging.NOTSET,
                        stream=sys.stdout,
                        format='%(asctime)s %(levelname)s: %(message)s')

    if len(sys.argv) <= 1:
        logging.error("Usage:  name-value.py <output-file>")
        sys.exit(-1)

    filename = sys.argv[1]
    try:
        dumpfile = open(filename, 'w')
    except (IOError, OSError), e:
        logging.error("Error opening output file '%s': %s" % (filename, e.strerror))
        sys.exit(-1)

    cursor = connection.cursor()
    cursor.execute('BEGIN')

    try:
        # Note: count() is relatively expensive with InnoDB, so don't call it more
        # than we absolutely have to.  Since this is being done within a
        # transaction, the count should never change.
        issues = Issue.objects.filter(series__country__code='us', deleted=False) \
                              .order_by().select_related(
          'series',
          'series__publisher',
          'brand',
          'indicia_publisher',
          'series__language',
          'series__country',
          'series__publisher__country')
        max = issues.aggregate(models.Max('id'))['id__max']

        _dump_table(dumpfile, issues, max, ISSUE_FIELDS, lambda i: i.id)

        stories = Story.objects.filter(issue__series__country__code='us',
                                       type__name__in=STORY_TYPES,
                                       deleted=False) \
                               .order_by() \
                               .select_related('type')
        max = stories.aggregate(models.Max('id'))['id__max']
        _dump_table(dumpfile, stories, max, STORY_FIELDS, lambda s: s.issue_id)

    finally:
        # We shouldn't have anything to commit or roll back, so just to be safe,
        # use a rollback to end the transation.
        cursor.execute('ROLLBACK')

if __name__ == '__main__':
    main()

