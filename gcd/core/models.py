from django.db import models

SERVER_COMICS_ORG = 1
SERVER_GCDCOVERS_COM = 2

SERVER_MAP = {
    SERVER_COMICS_ORG: 'http://www.comics.org/',
    SERVER_GCDCOVERS_COM: 'http://www.gcdcovers.com/',
}

SERVER_CHOICES = [
    (SERVER_COMICS_ORG, 'Old Server'),
    (SERVER_GCDCOVERS_COM, 'Current Server'),
]

TYPE_CHOICES = [
    (u'cover', u'Cover'),
    (u'story', u'Story'),
    (u'text story', u'Text Story'),
    (u'text article', u'Text Article'),
    (u'photo story', u'Photo Story'),
    (u'activity', u'Activity'),
    (u'ad', u'Advertisement'),
    (u'bio', u'Biography (nonfictional)'),
    (u'cartoon', 'Cartoon'),
    (u'profile', u'Character Profile'),
    (u'cover reprint', u'Cover Reprint (on interior page)'),
    (u'credits', u'Credits'),
    (u'filler', u'Filler'),
    (u'foreward', u'Forward, Introduction, Preface, Afterward'),
    (u'pinup', u'Illustration'),
    (u'insert', u'Insert or Dust Jacket'),
    (u'letters', u'Letters Page'),
    (u'promo', u'Promo (by the issue\'s publisher)'),
    (u'psa', u'Public Service Announcement'),
    (u'recap', u'Recap'),
    (u'backcovers', u'-- DO NOT USE / PLEASE FIX -- Back Cover'),
]

TYPE_MAP = dict(TYPE_CHOICES)

#########################################################################
# Core Data Tables
#########################################################################

class Publisher(models.Model):
    """
    The representation of any kind of publisher.

    This includes generic "house names", imprints, legal corporations,
    surrogate publishers, etc.  Currently all of these concepts are
    sorted into either "Master Publisher" or "Imprint" (see the proxy
    models for those concepts.
    """

    class Meta:
        ordering = ['name']
        app_label = 'core'

    doc_urls = {
        'name': 'http://docs.comics.org/wiki/Publisher_Name',
        'country': 'http://docs.comics.org/wiki/Country',
        'years': 'http://docs.comics.org/wiki/Years_of_Operation',
        'notes': 'http://docs.comics.org/wiki/Notes',
        'url': 'http://docs.comics.org/wiki/Website',
        'imprint': 'http://docs.comics.org/wiki/Imprint',
    }

    doc = '<a href="%s">(help)</a>'

    # Core publisher fields.
    name = models.CharField(max_length=255, db_index=True,
      help_text=(('For master publishers <a href="%s">(help)</a>, the common ' +
                  '(rather than legal) name of the publisher. For imprints ' +
                  '<a href="%s">(help)</a> the legal name or names.') %
                  (doc_urls['name'], doc_urls['imprint'])))
    country = models.ForeignKey('Country', null=True,
      related_name='publishers',
      help_text=('Country of the publisher\'s primary office. ' +
                 doc % doc_urls['country']))
    year_began = models.IntegerField(db_index=True,
      help_text=('Year in which the publisher begain operations. ' +
                 doc % doc_urls['years']))
    year_ended = models.IntegerField(null=True, blank=True,
      help_text=('Year in which the publisher ceased operations. ' +
                 'Leave blank if still in operation. ' +
                 doc % doc_urls['years']))
    notes = models.TextField(null=True, blank=True,
      help_text=('Additional information about the publisher. ' +
                 'No opinions or similar commentary, please. ' +
                 doc % doc_urls['notes']))
    url = models.URLField(null=True, blank=True,
      help_text='The publisher\'s web site.')

    # Fields about relating publishers/imprints to each other.
    master = models.BooleanField(db_index=True,
      help_text=(('Check this box if this publisher is <strong>not</strong> ' +
                  'an imprint <a href="%s">(help)</a> or subsidiary of ' +
                  'another publisher in the database.') %
                 doc_urls['imprint']))

    parent = models.ForeignKey('MasterPublisher', null=True, blank=True,
      db_index=True,
      related_name='imprints',
      limit_choices_to={ 'master': 1 },
      help_text=(('Parent company of this publisher if it is an ' +
                  'imprint <a href="%s">(help)</a> or subsidiary.') %
                 doc_urls['imprint']))

    # This seems to help sort related publishers together despite spelling.
    alpha_sort_code = models.CharField(max_length=1, null=True, blank=True,
      help_text='Used to group related publishers.  Or something.')

    # Cached counts.
    series_count = models.IntegerField(default=0, editable=False)
    issue_count = models.IntegerField(default=0, editable=False)

    # Fields related to change management.
    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now_add=True, auto_now=True,
                                editable=False)

    def __unicode__(self):
        if self.master and self.country:
            return u'%s (%s, %s, %d series)' % (self.name,
                                                self.country.code,
                                                self.year_began,
                                                self.series_count)
        elif self.master:
            return u'%s (%s, %d series)' % (self.name, self.year_began,
                                            self.series_count)
        elif self.country:
            return u'%s (%s, %s)' % (self.name, self.country.code,
                                     self.year_began)
        else:
            return u'%s (%s)' % (self.name, self.year_began)

    def has_imprints(self):
        return self.imprints.count() > 0

    def get_absolute_url(self):
        return "/publisher/%i/" % self.id

    def get_official_url(self):
        try:
            if not self.url.lower().startswith('http://'):
                self.url = "http://" + self.url
        except:
            return ""

        return self.url

class MasterPublisherManager(models.Manager):
    """
    Special manager to filter the Publisher table for the MasterPublisher proxy.
    """
    def get_query_set(self):
        return super(MasterPublisherManager, self).get_query_set().filter(
            master=1)

class MasterPublisher(Publisher):
    """
    A proxy class representing only the master publishers from the table.
    """
    class Meta:
        proxy = True
        ordering = ['name']
        app_label = 'core'

    objects = MasterPublisherManager()

class ImprintManager(models.Manager):
    """
    Special manager to filter the Publisher table for the Impriint proxy.
    """
    def get_query_set(self):
        return super(ImprintManager, self).get_query_set().filter(
            parent__isnull=False)

class Imprint(Publisher):
    """
    A proxy class representing only imprints from the publisher table.
    """
    class Meta:
        proxy = True
        ordering = ['name']
        app_label = 'core'

    objects = ImprintManager()

    def get_absolute_url(self):
        return "/imprint/%i/" % self.id

class Series(models.Model):
    """
    The represnatation of a comic book series.
    """
    class Meta:
        app_label = 'core'
        ordering = ['name', 'year_began']
        verbose_name_plural = 'series'
    
    doc_urls = {
        'name': 'http://docs.comics.org/wiki/Book_Name',
        'imprint': 'http://docs.comics.org/wiki/Imprint',
        'country': 'http://docs.comics.org/wiki/Country_Code',
        'language': 'http://docs.comics.org/wiki/Language_Code',
        'format': 'http://docs.comics.org/wiki/Format',
        'publication_years': 'http://docs.comics.org/wiki/Years_of_Publication',
        'publication_dates': 'http://docs.comics.org/wiki/Publication_Dates',
        'issue_range': 'http://docs.comics.org/wiki/Issue_Range',
        'notes': 'http://docs.comics.org/wiki/Series_Notes',
        'publication_notes': 'http://docs.comics.org/wiki/Publisher_Notes',
        'tracking_notes': 'http://docs.comics.org/wiki/Tracking',
    }

    doc = '<a href="%s">(help)</a>'

    # Core series fields.
    name = models.CharField(max_length=255, db_index=True,
      help_text=(doc % doc_urls['name']))
    format = models.CharField(max_length=255, null=True,
      help_text=(doc % doc_urls['format']))
    year_began = models.IntegerField(db_index=True,
      help_text=(doc % doc_urls['publication_years']))
    year_ended = models.IntegerField(null=True, blank=True,
      help_text=(doc % doc_urls['publication_years']))
    publication_dates = models.CharField(max_length=255, null=True, blank=True,
      help_text=(doc % doc_urls['publication_dates']))

    # Country info- for some reason not a foreign key to Countries table.
    country_code = models.CharField(max_length=4, null=True,
      help_text=(doc % doc_urls['country']))
    # Language info- for some reason not a foreign key to Languages table.
    language_code = models.CharField(max_length=3, null=True, db_index=True,
      help_text=(doc % doc_urls['language']))

    # Fields related to the publishers table.
    publisher = models.ForeignKey(MasterPublisher, db_index=True,
      related_name='series',
      help_text=('Click the magnifying glass to search for the correct ' +
                 'publisher ID number.  The text next to the box will not ' +
                 'change until after you save this page. '))
    imprint = models.ForeignKey(Imprint, null=True, blank=True, db_index=True,
      related_name='series',
      help_text=(('Click the magnifying glass to search for the correct ' +
                  'imprint %s ID number.  The text next to the box will not ' +
                  'change until after you save this page. ') %
                 (doc % doc_urls['imprint'])))

    # Issue tracking info that should probably be read from issues table.
    # Note that in the issues table, issues can be 25 characters.
    first_issue = models.CharField(max_length=25, null=True, blank=True,
      help_text=(doc % doc_urls['issue_range']))
    last_issue = models.CharField(max_length=25, null=True, blank=True,
      help_text=(doc % doc_urls['issue_range']))

    publication_notes = models.TextField(null=True, blank=True,
      help_text=(doc % doc_urls['publication_notes']))
    tracking_notes = models.TextField(null=True, blank=True,
      help_text=(doc % doc_urls['tracking_notes']))
    notes = models.TextField(null=True, blank=True,
      help_text=(doc % doc_urls['notes']))

    # Fields related to cover image galleries.
    has_gallery = models.BooleanField(editable=False, db_index=True)
    
    # Fields related to indexing activities.
    indexers = models.ManyToManyField('Indexer', through='SeriesCredit')
    open_reserve = models.IntegerField(null=True, blank=True, editable=False)

    # Cached fields.
    issue_count = models.IntegerField(default=0, editable=False)
    publisher_name = models.CharField(max_length=255, editable=False)

    # Fields related to change management.
    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now_add=True, auto_now=True,
                                editable=False)
    modification_time = models.TimeField(auto_now_add=True, auto_now=True,
                                         editable=False)

    def get_absolute_url(self):
        return '/series/%i/' % self.id

    def scan_count(self):
        return self.cover_set.filter(has_image='1').count()

    def __unicode__(self):
        return u'%s (%s, %s)' % (self.name, self.publisher_name,
                                 self.year_began)

class Issue(models.Model):
    """
    The representation of a single comic book issue.
    """

    class Meta:
        app_label = 'core'
        ordering = ['series_name', 'sort_code']

    doc_urls = {
        'number': 'http://docs.comics.org/wiki/Issue_Numbers',
        'volume': 'http://docs.comics.org/wiki/Volume',
        'key_date': 'http://docs.comics.org/wiki/Keydate',
        'publication_date': 'http://docs.comics.org/wiki/Published_Date',
        'price': 'http://docs.comics.org/wiki/Price',
        'editing': 'http://docs.comics.org/wiki/Editing',
        'notes': 'http://docs.comics.org/wiki/Notes',
    }

    doc = '<a href="%s">(help)</a>'

    # Core issue attributes.
    # Note that volume is not consistently used at this time, and
    # is usually included in 'issue' when it is of critical importance.
    number = models.CharField(max_length=50,
      help_text=('Issue numbers may be non-numeric (e.g. "5a", "v2#10", ' +
                 '"Summer Special", "[nn]", etc.). ' +
                 doc % doc_urls['number']))
    volume = models.IntegerField(null=True, blank=True,
      help_text=('Leave blank if no volume number is printed. ' +
                 doc % doc_urls['volume']))
    series = models.ForeignKey(Series, db_index=True, related_name='issues')

    key_date = models.CharField(max_length=10, null=True, blank=True,
      db_index=True,
      help_text=('Format is YYYY.MM.DD, used as an alternative sort code. ' +
                 doc % doc_urls['key_date']))

    # This field is not directly visible to the user.
    sort_code = models.IntegerField(db_index=True)

    # Note that in stories, publication_date is limited to 50 chars.
    publication_date = models.CharField(max_length=255, null=True, blank=True,
      help_text=('Do not abbreviate months, otherwise record as printed. ' +
                 doc % doc_urls['publication_date']))
    price = models.CharField(max_length=255, null=True, blank=True,
      help_text=('Format is a decimal number followed by the ISO ' +
                 'currency code, i.e. 3.50 CAD for $3.50 Canadian. ' +
                 doc % doc_urls['price']))
    page_count = models.CharField(max_length=10, null=True, blank=True,
      help_text='Total page count of the book, counting covers but not ' +
                'inserts or dust jackets.')

    editing = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('Editor and similar credits that apply to the entire issue. ' +
                 'Individual sequence editors should be recorded for each ' +
                 'sequence. ' + doc % doc_urls['editing']))
    notes = models.TextField(null=True, blank=True,
      help_text=('Explanations of unclear or speculative data that applies ' +
                 'to the entire issue.  Also any additional information ' +
                 'such as the indicia.  Please, no opinions or similar ' +
                 'commentary. ' + doc % doc_urls['notes']))

    target_issuess = models.ManyToManyField('self', through='IssueReprint',
      symmetrical=False, related_name='source_issues')

    # Fields related to indexing activities.
    index_status = models.IntegerField(default=0, editable=False, db_index=True)
    reserve_status = models.IntegerField(default=0, editable=False,
      db_index=True)

    # Cached fields.
    sequence_count = models.IntegerField(default=0, editable=False)
    series_name = models.CharField(max_length=255, db_index=True)
    year_began = models.IntegerField(null=False, default=0, editable=False)
    publisher_name = models.CharField(max_length=255, editable=False)

    # Fields related to change management.
    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now=True, editable=False)
    modification_time = models.TimeField(auto_now=True, editable=False)
    
    def index_status_description(self):
        """Text form of status.  If clauses arranged in order of most
        likely case to least."""
        if (self.index_status == 3):
            return 'approved'
        if (self.index_status == 0):
            return 'no data'
        if (self.index_status == 1):
            return 'reserved'
        if (self.index_status == 2):
            return 'pending'

    def get_absolute_url(self):
        return "/issue/%i/" % self.id

    def __unicode__(self):
        return u'%s #%s' % (self.series_name, self.number)

class Sequence(models.Model):
    """
    The representation of a single unit of content within a comic book.

    Naming this object has been a source of much controversy, with
    "sequence" being familiar and reasonably accurate even though
    some kinds of sequences are not sequential within themselves
    (single page illustrations, most ads, etc.).
    """
    class Meta:
        app_label = 'core'
        ordering = ['number']
        unique_together = [('issue', 'number')]

    doc_urls = {
        'number': 'http://docs.comics.org/wiki/Sequence_Number',
        'page_count': 'http://docs.comics.org/wiki/Page_Count',
        'job_number': 'http://docs.comics.org/wiki/Job_Number',
        'type': 'http://docs.comics.org/wiki/Type',
        'title': 'http://docs.comics.org/wiki/Title',
        'feature': 'http://docs.comics.org/wiki/Feature',
        'genre': 'http://docs.comics.org/wiki/Genre',
        'credits': 'http://docs.comics.org/wiki/Credits',
        'script': 'http://docs.comics.org/wiki/Script',
        'pencils': 'http://docs.comics.org/wiki/Pencils',
        'inks': 'http://docs.comics.org/wiki/Inks',
        'colors': 'http://docs.comics.org/wiki/Colors',
        'letters': 'http://docs.comics.org/wiki/Letters',
        'editing': 'http://docs.comics.org/wiki/Editing',
        'characters': 'http://docs.comics.org/wiki/Character_Appearances',
        'reprints': 'http://docs.comics.org/wiki/Reprints',
        'synopsis': 'http://docs.comics.org/wiki/Synopsis',
        'notes': 'http://docs.comics.org/wiki/Notes',
    }

    doc = '<a href="%s">(help)</a>'
    doc_terse_credits = \
      '<a href="http://docs.comics.org/wiki/Credits">(help for credits)' + \
      '</a> <a href="%s">(help for %s)</a>'
    doc_prefix_credits = \
      'Use "none" (without quotes) if the credit does not apply, ' + \
      '"?" if the credit is unknown. '
    doc_credits = doc_prefix_credits + doc_terse_credits

    # Core content fields.
    title = models.CharField(max_length=255, null=True, blank=True,
        db_index=True, help_text=('Title, may be [Made Up] or ["First line ' +
                                  'of story"] if there is no proper title. ' +
                                  doc % doc_urls['title']))
    feature = models.CharField(max_length=255, null=True, blank=True,
      db_index=True, help_text=(doc % doc_urls['feature']))
    number = models.IntegerField(db_index=True,
      help_text=('Number of the sequence within the issue. ' +
                 'The first cover must be sequence number 0. ' +
                 doc % doc_urls['number']))
    page_count = models.CharField(max_length=10, null=True, blank=True,
      help_text=('Number of pages.  For covers, wraparounds are 2 pages, ' +
                 'fold-outs count each folded section as a page. ' +
                 doc % doc_urls['page_count']))

    type = models.CharField(max_length=50, null=True, blank=True,
      help_text=('Choose the most appropriate type from the list. ' +
                 doc % doc_urls['type']), choices=TYPE_CHOICES)

    job_number = models.CharField(max_length=25, null=True, blank=True,
      db_index=True, help_text=('A code used by the publisher to identify ' +
      'a piece of work.  Not always present. ' + doc % doc_urls['job_number']))

    # Credit fields.
    script = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('Writer, plotter or scripter. ' +
                 doc_credits % (doc_urls['script'], 'script')))
    pencils = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('Penciler, painter or other primary artist such as ' +
                 'photographer in a photo story. ' +
                 doc_credits % (doc_urls['pencils'], 'pencils')))
    inks = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=(doc_credits % (doc_urls['inks'], 'inks')))
    colors = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=((doc_prefix_credits + 'Use "none" for black and white. ' +
                  doc_terse_credits) % (doc_urls['colors'], 'colors')))
    letters = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=(doc_credits % (doc_urls['letters'], 'letters')))
    editing = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('Leave blank unless there is a different editor for ' +
                 'this sequence than for the rest of the issue. ' +
                 doc_terse_credits % (doc_urls['editing'], 'editing')))

    # Content fields.
    genre = models.CharField(max_length=255, null=True, blank=True,
      help_text=('At least one genre should come from the list of approved ' +
                 'genres.  No more than three genres should be used. ' +
                 doc % doc_urls['genre']))
    characters = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('List the significant and/or recurring characters. ' +
                 doc % doc_urls['characters']))
    synopsis = models.TextField(null=True, blank=True,
      help_text=('A brief description of the contents, just enough to ' +
                 'identify the story if seen elsewhere. ' +
                 doc % doc_urls['synopsis']))

    # Reprint fields.
    targets = models.ManyToManyField('self', through='Reprint',
      symmetrical=False, related_name='sources')
    source_issues = models.ManyToManyField('Issue', through='ReprintFromIssue',
      related_name='targets')
    target_issues = models.ManyToManyField('Issue', through='ReprintToIssue',
      related_name='sources')

    reprint_notes = models.TextField(null=True, blank=True, # Indexed in MySQL,
      help_text=('Please follow the documented format exactly to help ' +
                 'migrate this field to database inks where possible. ' +
                 doc % doc_urls['reprints']))

    # Note fields.
    notes = models.TextField(null=True, blank=True,
      help_text=('Any explanations of credits or other notes for the ' +
                 'sequence.  No opinions or similar commentary, please. ' +
                 doc % doc_urls['notes']))

    # Fields from issue.
    issue = models.ForeignKey(Issue, db_index=True, related_name='sequences')
    issue_number = models.CharField(max_length=50, editable=False)

    # Fields from series.
    # Some strange defaults here so that the initial INSERT statement
    # will be accepted.  The defaults are fixed by a pre-INSERT trigger.
    series = models.ForeignKey(Series, default=0, db_index=True,
                                       related_name='sequences')
    series_name = models.CharField(max_length=255, editable=False)
    year_began = models.IntegerField(db_index=True, null=False, default=0,
                                     editable=False)

    # Fields from publisher.
    publisher_name = models.CharField(max_length=255, editable=False)

    # Fields related to change management.
    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now_add=True, auto_now=True,
                                editable=False, db_index=True)
    modification_time = models.TimeField(auto_now_add=True, auto_now=True,
                                         editable=False)

    def has_credits(self):
        """Simplifies UI checks for conditionals.  Credit fields."""
        return self.script or \
               self.pencils or \
               self.inks or \
               self.colors or \
               self.letters or \
               self.editing or \
               self.job_number

    def has_content(self):
        """Simplifies UI checks for conditionals.  Content fields"""
        return self.genre or \
               self.characters or \
               self.synopsis or \
               self.reprint_notes

    def has_data(self):
        """Simplifies UI checks for conditionals.  All non-heading fields"""
        return self.has_credits() or self.has_content() or self.notes

    def __unicode__(self):
        title = u'[no title indexed]'
        feature = u''
        page_count = u''
        type = u''
        if self.title:
            title = self.title
        if self.feature:
            feature = u'%s, ' % self.feature
        if self.type:
            type = TYPE_MAP[self.type]
        if self.page_count:
            page_count = u': %s' % self.page_count
        return u'%s (%s%s%s)' % (title, feature,
                                 type, page_count)


#########################################################################
# Reprints
#########################################################################

class Reprint(models.Model):
    """
    Mapping table for the 
    """
    class Meta:
        app_label = 'core'

    target = models.ForeignKey('Sequence', related_name='source_reprints',
                                           to_field=id)
    source = models.ForeignKey('Sequence', related_name='target_reprints',
                                           to_field=id)
    notes = models.TextField()

class ReprintToIssue(models.Model):
    class Meta:
        app_label = 'core'
        db_table = 'core_reprint_to_issue'

    target_issue = models.ForeignKey('Issue', related_name='source_reprints')
    source = models.ForeignKey('Sequence', related_name='target_issue_reprints')
    notes = models.TextField()

class ReprintFromIssue(models.Model):
    class Meta:
        app_label = 'core'
        db_table = 'core_reprint_from_issue'

    target = models.ForeignKey('Sequence', related_name='source_issue_reprints')
    source_issue = models.ForeignKey('Issue', related_name='target_reprints')
    notes = models.TextField()

class IssueReprint(models.Model):
    class Meta:
        app_label = 'core'
        db_table = 'core_issue_reprint'

    target_issue = models.ForeignKey('Issue', to_field=id,
                                     related_name='source_issue_reprints')
    source_issue = models.ForeignKey('Issue', to_field=id,
                                     related_name='target_issue_reprints')
    notes = models.TextField()

#########################################################################
# Images
#########################################################################

class Cover(models.Model):
    """
    Covers table.  Will eventually just be the images table.
    """

    class Meta:
        app_label = 'core'
        ordering = ['issue_sort_code']

    # Issues can have multiple covers, and may also link to other
    # sorts of images such as splash page scans.
    issue = models.ForeignKey(Issue, db_index=True, related_name='images')

    # The number field from the related issue.  May or may not agree with
    # the issue field in practice when combined with the series field.
    issue_number = models.CharField(max_length=50)
    series = models.ForeignKey(Series, db_index=True, default=0,
                                       related_name='images')

    sequence_number = models.IntegerField(null=True, blank=True,
      help_text=('The sequence with which this image is associated.'))

    # Location code is the old sort code, now used only to locate
    # the image in the file system.  issue_sort_code caches the new
    # sort code from the issue table, and is not directly visible
    # to the end user.
    location_code = models.CharField(max_length=50, db_index=True,
                                     default='000', editable=False)
    issue_sort_code = models.IntegerField(editable=False)

    # Fields directly related to images
    has_image = models.BooleanField(db_index=True)
    marked = models.BooleanField(db_index=True,
      help_text='Check if a replacement image is needed')

    has_small = models.BooleanField(db_index=True)
    has_medium = models.BooleanField(db_index=True)
    has_large = models.BooleanField(db_index=True)

    server_version = models.PositiveIntegerField(null=False, blank=True,
      default=SERVER_GCDCOVERS_COM, choices=SERVER_CHOICES)

    # Theoretically an EmailField, but not so much in practice.
    contributor = models.CharField(max_length=255, null=True, blank=True)

    # Attributes from publishers table
    publisher_name = models.CharField(max_length=255)

    # Series attributes
    series_name = models.CharField(max_length=255)
    year_began = models.IntegerField(null=False, default=0, db_index=True)

    # Fields related to change management.
    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now_add=True, auto_now=True,
                                editable=False, db_index=True)
    creation_time = models.TimeField(auto_now_add=True, editable=False)
    modification_time = models.TimeField(auto_now_add=True,
                                         auto_now=True, editable=False)

    def get_cover_status(self):
        import logging
        if self.marked:
            return 4
        if self.has_large != 0:
            return 3
        if self.has_medium != 0:
            return 2
        if self.has_small != 0:
            return 1
        return 0

    def __unicode__(self):
        return u'%s #%s' % (self.issue.series_name, self.issue.number)

#########################################################################
# Supporting Data Tables
#########################################################################

class Country(models.Model):
    class Meta:
        app_label = 'core'
        verbose_name_plural = 'countries'
        ordering = ['code']

    code = models.CharField(max_length=10, db_index=True, unique=True,
      help_text='The ISO country code')
    name = models.CharField(max_length=255, db_index=True,
      help_text='The country name')

    def __unicode__(self):
        return u'%s %s' % (self.code, self.name)

class Language(models.Model):
    class Meta:
        app_label = 'core'
        ordering = ['code']

    code = models.CharField(max_length=10, db_index=True, unique=True,
      help_text='The ISO language code')
    name = models.CharField(max_length=255, db_index=True,
      help_text='The name of the language')

    def __unicode__(self):
        return u'%s %s' % (self.code, self.name)

#########################################################################
# Account Management and Credits
#########################################################################

class Indexer(models.Model):
    """
    Indexer from gcd database
    """

    class Meta:
        app_label = 'core'
        ordering = ['family_name', 'given_name']

    # Passwords can be NULL/blank because of dev environment issues.
    username = models.CharField(max_length=255, db_index=True)
    password = models.CharField(max_length=255, db_index=True)

    # This is not quite the country code from other fields, but is clearly
    # supposed to use two-letter codes even though not all entries do.
    country_code = models.CharField(max_length=50, null=True,
      help_text='Two-letter ISO country code of the indexer\'s nationality')

    email = models.EmailField(db_index=True)

    given_name = models.CharField(max_length=255, null=True, blank=True,
      db_index=True)
    family_name = models.CharField(max_length=255, null=True, blank=True,
      db_index=True)

    name_order = models.BooleanField(default=0)

    user_level = models.IntegerField(default=1)
    active = models.BooleanField(default=1)

    message = models.TextField(null=True, blank=True)

    created = models.DateField(auto_now_add=True, editable=False)
    modified = models.DateField(auto_now_add=True, auto_now=True,
                                editable=False)

    def __unicode__(self):
        given = self.given_name
        family = self.family_name
        if given is None:
            given = ''
        if family is None:
            family = ''

        separator = ' '
        if '' in (given, family):
            separator = ''
        return '%s%s%s' % (given, separator, family)

class SeriesCredit(models.Model):
    """
    Join table from series to indexers for old series-level credits.
    Formerly IndexCredit, which was a bit misleading.
    """

    class Meta:
        app_label = 'core'
        ordering = ['series', 'indexer']

    indexer = models.ForeignKey(Indexer, related_name='series_credits',
      db_index=True, editable=False)
    series = models.ForeignKey(Series, related_name='series_credits',
      db_index=True, editable=False)
    run = models.CharField(max_length=255, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    modified = models.DateField(auto_now=True, editable=False)

    def __unicode__(self):
        return u'%s: %s' % (self.series, self.indexer)

