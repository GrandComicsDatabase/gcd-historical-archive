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
from apps.gcd.models import *


# TODO: When we move up to Python 2.6 (or even 2.5) these related name access
# functions can all be replaced by the "x if foo else y" construct in a lambda.

def _imprint_name(issue):
    if issue.series.imprint:
        return issue.series.imprint.name
    return u''

def _brand_name(issue):
    if issue.brand:
        return issue.brand.name
    return u''

def _indicia_publisher_name(issue):
    if issue.indicia_publisher:
        return issue.indicia_publisher.name
    return u''

def _volume(issue):
    if issue.volume is None:
        return u''
    return u'%d' % issue.volume

def _page_count(issue):
    if issue.page_count is None:
        return u''
    return u'%d' % issue.page_count


# Map moderately human-friendly field names to functions producing the data from
# an issue record.
ISSUE_FIELDS = {'series name': lambda i: i.series.name or u'',
                'issue number': lambda i: i.number,
                'volume': _volume,
                'no volume': lambda i: i.no_volume,
                'display number': lambda i: i.display_number,
                'price': lambda i: i.price or u'',
                'issue page count': _page_count,
                'issue page count uncertain': lambda i: i.page_count_uncertain,
                'publication date': lambda i: i.publication_date or u'',
                'key date': lambda i: i.key_date or u'',
                'publisher name': lambda i: i.series.publisher.name,
                'imprint name': _imprint_name,
                'brand name': _brand_name,
                'indicia publisher name': _indicia_publisher_name}

    
# Map moderately human-friendly field names to functions producing the data from
# a story record.
STORY_FIELDS = {'title': lambda s: s.title,
                'title by gcd': lambda s: s.title_inferred,
                'feature': lambda s: s.feature,
                'script': lambda s: s.script,
                'no script': lambda s: s.no_script,
                'pencils': lambda s: s.pencils,
                'no pencils': lambda s: s.no_pencils,
                'inks': lambda s: s.inks,
                'no inks': lambda s: s.no_inks,
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

def _fix_value(value):
    """
    Values that are null should produce two adjacent field separators with no
    characters between them (or a field separator followed by a line separator).
    Values that are empty strings should appear as such (quoted).
    """
    if value is None:
        value = u''
    else:
        value = u'"' + value + u'"'
    return value

def main():
    if len(sys.argv) <= 1:
        print "Usage:  name-value.py <output-file>"
        sys.exit(-1)

    filename = sys.argv[1]
    try:
        dumpfile = open(filename, 'w')
    except (IOError, OSError), e:
        print "Error opening output file '%s': %s" % (filename, e.strerror)
        sys.exit(-1)

    related = ('series',
               'series__publisher',
               'series__imprint',
               'brand',
               'indicia_publisher')
    for issue in Issue.objects.order_by().select_related(*related).iterator():
        for name, func in ISSUE_FIELDS.items():
            value = unicode(func(issue)).replace(u'"', u'""')
            value = _fix_value(value)
            record = u'"%d"\t"%s"\t%s\n' % (issue.id, name, value)
            dumpfile.write(record.encode('utf-8'))

    stories = Story.objects.filter(type__name__in=STORY_TYPES)
    for story in stories.select_related('type').order_by().iterator():
        for name, func in STORY_FIELDS.items():
            value = unicode(func(story)).replace(u'"', u'""')
            value = _fix_value(value)
            record = u'"%d"\t"%s"\t%s\n' % (story.issue_id, name, value)
            dumpfile.write(record.encode('utf-8'))


if __name__ == '__main__':
    main()

