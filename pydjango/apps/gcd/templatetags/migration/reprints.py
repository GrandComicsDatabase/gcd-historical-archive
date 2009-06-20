# -*- coding: utf-8 -*-
# coding=utf-8
from django import template
from django.utils.translation import ugettext as _
from django.utils.safestring import mark_safe
from django.utils.html import conditional_escape as esc

from apps.gcd.models import Issue,Story

register = template.Library()

# list checks we should/could do when we use this for the migration
# - keydate of from should be smaller, keydate of to should be larger
# - if no keydate exists on one side maybe check on series year
# - search for title match of story as well
# - search for matching page count
# - search for reprint link back

# other stuff to consider in the display
# - sort the reprints according to keydate
# - sort domestic/foreign reprints

def find_reprint_sequence_in_issue(from_story,to_issue):
    '''look for sequence in <to_issue> which fits <from_story>'''
    
    results = Story.objects.all()
    results = results.filter(issue__id = to_issue)
    results = results.filter(title__icontains = from_story.title.strip().strip('!').strip('.'))
    if (results.count() > 1):
        try:
            results = results.filter(page_count = from_story.page_count)
        except:
            pass
    if (results.count() == 1):
        return results[0].sequence_number
    #for i in range(results.count()):
        #print results[i].title
    return -1


def generate_reprint_link(from_story, to_issue, from_to, style, notes=None,
                          li=True):
    ''' generate reprint link to_issue'''
    
    link = "<a href=\"/gcd/issue/"+str(to_issue.id)
    sequence = find_reprint_sequence_in_issue(from_story,to_issue.id)
    link += "?style=" + style + "&reprints=True"
    if (sequence >= 0):
        link += "#" + esc(sequence)
    link += "\">"
#    link += "?style=" + style + "&reprints=True\">"

    link += esc(from_to) + esc(to_issue.series.name) 
    link += " (" + esc(to_issue.series.publisher) + ", "
    link += esc(to_issue.series.year_began) + " series) #"
    link += esc(to_issue.number) + "</a>"
    if notes:
        link += esc(notes)
    link += " (" + esc(to_issue.publication_date) + ")"
    if li:
        return '<li> ' + link + ' </li>'
    else:
        return link    

def generate_candidates_link(story, reprint_string, candidates, from_to, style):
    ''' generate links for candidate reprints to_issue'''

    link = "<li>" + esc(reprint_string) + '\t candidate(s):\n'
    for i in candidates:
        link += generate_reprint_link(story, i,
                                         from_to, style, li=False)
        link += '\n editors please edit the <a target="_blank" href=\"http://www.comics.org/admin/system/modules/site.lasso?mode=update&type=story&storyid='+esc(story.id)+'\">database</a>\n'
    link += '</li>'
    return link

def parse_reprint_fr(reprints):
    """ parse a reprint entry starting with "fr." Often found in older indices.
    Don't trust this parsing too much."""

    try:# for format: fr. seriesp #nr (issue date) date unused for parsing
        position = reprints.find(' #')
        series = reprints[3:position].strip()
        position += 2
        string = reprints[position:]
        position = string.find('(')
        number = string[:position].strip()
        results = Issue.objects.all()
        results = results.filter(series__name__icontains = series)
        results = results.filter(number__exact = number)
    except:
        pass
    
    if results.count() == 0 or results.count() > 10:
        try:# for format: from seriesname #nr (issue date) date unused for parsing
            #and for format: from seriesname #nr
            position = reprints.find(' #')
            if reprints.lower().startswith('from'):
                series = reprints[4:position].strip()
            elif reprints.lower().startswith('rpt. from'):
                series = reprints[9:position].strip()
            elif reprints.lower().startswith('rep from'):
                series = reprints[8:position].strip()
            else:
                return Issue.objects.none()
            position += 2
            string = reprints[position:]
            position = string.find('(')
            if position > 0:
                number = string[:position].strip()
                position_end = string.find(')')
                if position_end > position:
                    year = string[position_end-4:position_end]
            elif string.isdigit():#we don't even have (issue date)
                number = string
            else:
                number = string[:string.find(' ')].strip()
            results = Issue.objects.all()
            results = results.filter(series__name__icontains = series)
            results = results.filter(number__exact = number)
            if year:
                results = results.filter(key_date__icontains = year)
        except:
            pass
    
    return results


def parse_reprint_full(reprints, from_to, max_found = 10):
    """ parse a reprint entry, first for our standard, them some for
    other common version.  We may turn the others off or add even more. ;-)"""
    notes = None
    
    if reprints.lower().startswith(from_to):
        try:# our preferred format: seriesname (publisher, year <series>) #nr
            position = reprints.find(' (')
            series = reprints[len(from_to):position].strip("Tthe ")
            string = reprints[position+2:]
            after_series = string # use in other formats
            end_bracket = string.find(')')
            position = string[:end_bracket].rfind(', ')
            publisher = string[:position].strip()
            position+=2
            string = string[position:]
            year = string[:4]
            if from_to in ['da ', 'in ', 'de ', 'en ']: #italian and spanish from/in
                if year.isdigit() != True:
                    position = string.find(')')
                    year = string[position-4:position]
            string = string[4:]
            position = string.find(' #')+2
            string = string[position:]
            position = string.find(' [') #check for notes
            if position > 0:
                position_end = string.find(']')
                if position_end > position:
                    notes = string[position:position_end+1]
                date_pos = string.find(' (') #check for (date)
                if date_pos > 0 and date_pos < position:
                    position = date_pos
            else:
                position = string.find(' (') #check for (date)
                if position > 0: #if found ignore later
                    pass
                else:
                    #allow #nr date without ( ) only 
                    #if there is a number before the space
                    position = string.find(' ') 
                    if position > 0:
                        if string[:position].isdigit():
                            pass
                        else:
                            position = 0
            if string.isdigit(): #in this case we are fine
                number = string
            else:
                if position > 0:
                    number = string[:position].strip()
                else:
                    number = string.strip().strip('.')
            results = Issue.objects.all()
            results = results.filter(series__name__icontains = series)
            results = results.filter(series__publisher__name__icontains 
            = publisher)
            results = results.filter(series__year_began__exact = int(year))
            results = results.filter(number__exact = number)
            if results.count() == 0 or results.count() > max_found:
                # try stripping ',.' from before whitespace/from the end
                position = string.find(' ') 
                if position > 0:
                    number = string[:position].strip('.,')
                else:
                    number = string.strip('.,')
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                results = results.filter(series__publisher__name__icontains 
                = publisher)
                results = results.filter(series__year_began__exact = int(year))
                results = results.filter(number__exact = number)
        except:
            pass
        
        if results.count() == 0 or results.count() > max_found:
            try:# our typoed format: seriesname (publisher year <series>) #nr
                # use series from before
                string = after_series
                position = string.find(' 1')
                if position > 0:
                    publisher = string[:position].strip()
                else:
                    position = string.find(' 2')
                    publisher = string[:position].strip()                    
                position+=1
                string = string[position:]
                year = string[:4]
                string = string[4:]
                position = string.find(' #')+2
                string = string[position:]
                position = string.find(' [') #check for notes
                if position > 0:
                    position_end = string.find(']')
                else:
                    position = string.find(' (') #check for (date)
                    if position > 0: #if found ignore later
                        position_end = 0
                if string.isdigit(): #in this case we are fine
                    number = string
                else:
                    if position > 0:
                        number = string[:position].strip()
                    else:
                        number = string.strip()
                if position > 0 and position_end > position:
                    notes = string[position:position_end+1]
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                results = results.filter(series__publisher__name__icontains 
                = publisher)
                results = results.filter(series__year_began__exact = int(year))
                results = results.filter(number__exact = number)
            except:
                pass
        
        if results.count() == 0 or results.count() > max_found:
            try:# for format: seriesname (year series) #nr
                # use series from before
                string = after_series
                year = string[:4]
                string = string[4:]
                position = string.find(' #')+2
                string = string[position:]
                if string.isdigit():
                    number = string
                else:
                    number = string[:string.find(' ')]
                position = string.find('[')
                position_end = string.find(']')
                if position > 0 and position_end > position:
                    notes = string[position:position_end+1]
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                results = results.filter(series__year_began__exact = int(year))
                results = results.filter(number__exact = number)
            except:
                pass
                
        if results.count() == 0 or results.count() > max_found:
            try:# for format: seriesname #nr(publisher, year <series>)
                position = reprints.find(' #')
                series = reprints[len(from_to):position].strip("Tthe ")
                position += 2
                string = reprints[position:]
                after_series = string
                position = string.find('(')
                number = string[:position].strip()
                position += 1
                string = string[position:]
                end_bracket = string.find(')')
                position = string[:end_bracket].rfind(', ')
                publisher = string[:position].strip()
                position += 2
                string = string[position:]
                year = string[:4]
                position = string.find('[')
                if position > 0:
                    notes = string[position:]
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                results = results.filter(series__publisher__name__icontains 
                = publisher)
                results = results.filter(series__year_began__exact = int(year))
                results = results.filter(number__exact = number)
            except:
                pass
                
        if results.count() == 0 or results.count() > max_found:
            try:# for format: seriesname #nr (year)
                # use series from before                
                string = after_series
                position = string.find('(')
                number = string[:position].strip()
                position += 1
                string = string[position:]
                year = string[:4]
                position = string.find('[')
                if position > 0:
                    notes = string[position:]
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                results = results.filter(series__year_began__exact = int(year))
                results = results.filter(number__exact = number)
            except:
                pass

        if from_to == u"från " and (results.count() == 0 or results.count() > max_found):
            try:# for format: seriesname #nr [country, publication year]
                # use series from before                
                string = after_series
                position = string.find('[')
                number = string[:position].strip()
                position += 1
                string = string[position:]
                position = string.find(']')
                pub_year = string[position-4:position]
                results = Issue.objects.all()
                results = results.filter(series__name__icontains = series)
                #results = results.filter(series__year_began__exact = int(year))
                results = results.filter(publication_date__icontains = pub_year)
                results = results.filter(number__exact = number)
            except:
                pass
        return results,notes
    else:
        return Issue.objects.none(),None


def show_reprint_full(story, style):
    """ Filter for reprint line.  First step into database migration.
    This routine is currently not being used. """
    
    if story.reprints:
        reprint = ""
        for string in story.reprints.split(';'):
            string = string.strip()
            # check for our format
            for from_to in ("from ","in ",""):
                next_reprint, notes = parse_reprint(string, from_to)
                if next_reprint.count() > 1 and next_reprint.count() <= 15:
                    a = []
                    for i in range(next_reprint.count()):
                        nr = find_reprint_sequence_in_issue(story,
                                                         next_reprint[i].id)
                        if (nr > 0):
                            a.append(i)
                    if len(a) == 1:
                        next_reprint = next_reprint.filter(id =
                                                next_reprint[a[0]].id)
                    if next_reprint.count() == 1:
                        reprint += generate_reprint_link(story, next_reprint[0],
                                                        from_to, style, 
                                                        notes=notes)
                        break
            # check for some others
            if next_reprint.count() != 1:
                for from_to in ("from ","in ",""):
                    next_reprint,notes = parse_reprint_full(string, from_to)
                    if next_reprint.count() > 1 and next_reprint.count() <= 15:
                        a = []
                        for i in range(next_reprint.count()):
                            nr = find_reprint_sequence_in_issue(story,
                                                            next_reprint[i].id)
                            if (nr > 0):
                                a.append(i)
                        if len(a) == 1:
                            next_reprint = next_reprint.filter(id =
                                                    next_reprint[a[0]].id)
                    if next_reprint.count() == 1:
                        reprint += generate_reprint_link(story, next_reprint[0],
                                                        from_to, style, 
                                                        notes=notes)
                        break
            # and some more obscure ones
            if next_reprint.count() != 1:
                next_reprint = parse_reprint_fr(string)
                if next_reprint.count() > 1 and next_reprint.count() <= 15:
                    a = []
                    for i in range(next_reprint.count()):
                        nr = find_reprint_sequence_in_issue(story,
                                                            next_reprint[i].id)
                        if (nr > 0):
                            a.append(i)
                    if len(a) == 1:
                        next_reprint = next_reprint.filter(id =
                                                next_reprint[a[0]].id)
                if next_reprint.count() == 1:
                    reprint += generate_reprint_link(story, next_reprint[0],
                                                     "from ", style)
                else:
                    reprint += '<li> ' + esc(string) + ' </li>'

        return mark_safe('<dt class="credit_tag">Reprints:</dt>' + \
                         '<dd class="credit_def"><ul> ' + reprint + \
                         '</ul></dd>')
    else:
        return ""
        
def show_reprint_suggestions(story, style):
    """ Filter for reprint line.  First step into database migration.
    If parsing does not work for the current format but for other formats
    prints the correct and link to edit it."""
    
    # if languages get added also add in check_reprints ! 
    reprint_direction = ["from ", "in "]
    if story.issue.series.language_code.lower() == 'it': #da, in
        reprint_direction = ["da "] + reprint_direction
    elif story.issue.series.language_code.lower() == 'es': #de, en
        reprint_direction = ["de ", "en "] + reprint_direction
    elif story.issue.series.language_code.lower() == 'nl': # uit, in
        reprint_direction = ["uit "] + reprint_direction 
    elif story.issue.series.language_code.lower() in ['sv', 'no']: # från, i
        reprint_direction = [u"från ", "i "] + reprint_direction 
    elif story.issue.series.language_code.lower() == 'de': # aus
        reprint_direction = ["aus "] + reprint_direction 
    reprint_direction_search = reprint_direction + [""]
    if story.reprints:
        reprint = ""
        for string in story.reprints.split(';'):
            string = string.strip()
            # check for our format
            for from_to in reprint_direction_search:
                next_reprint, notes = parse_reprint(string, from_to)
                if next_reprint.count() > 1 and next_reprint.count() <= 15:
                    a = []
                    for i in range(next_reprint.count()):
                        nr = find_reprint_sequence_in_issue(story,
                                                         next_reprint[i].id)
                        if (nr > 0):
                            a.append(i)
                    if len(a) == 1:
                        next_reprint = next_reprint.filter(id =
                                                next_reprint[a[0]].id)
                if next_reprint.count() == 1 and from_to in reprint_direction:
                    reprint += generate_reprint_link(story, next_reprint[0],
                                                     from_to, style,
                                                     notes = notes)
                    break
                elif next_reprint.count() > 0 and next_reprint.count() <= 5:
                    reprint += generate_candidates_link(story, string,
                                                next_reprint, from_to, style)
                    break
                        
            # check for some others
            if next_reprint.count() == 0 or next_reprint.count() > 5:
                for from_to in reprint_direction_search:
                    next_reprint,notes = parse_reprint_full(string, from_to)
                    if next_reprint.count() > 1 and next_reprint.count() <= 15:
                        a = []
                        for i in range(next_reprint.count()):
                            nr = find_reprint_sequence_in_issue(story,
                                                            next_reprint[i].id)
                            if (nr > 0):
                                a.append(i)
                        if len(a) == 1:
                            next_reprint = next_reprint.filter(id =
                                                    next_reprint[a[0]].id)
                    if next_reprint.count() > 0 and next_reprint.count() <= 5:
                        reprint += generate_candidates_link(story, string,
                                                next_reprint, from_to, style)
                        break
            if next_reprint.count() == 0 or next_reprint.count() > 5:
                next_reprint = parse_reprint_fr(string)
                if next_reprint.count() > 1 and next_reprint.count() <= 15:
                    a = []
                    for i in range(next_reprint.count()):
                        nr = find_reprint_sequence_in_issue(story,
                                                            next_reprint[i].id)
                        if (nr > 0):
                            a.append(i)
                    if len(a) == 1:
                        next_reprint = next_reprint.filter(id =
                                                next_reprint[a[0]].id)
                if next_reprint.count() > 0 and next_reprint.count() <= 5:
                    reprint += generate_candidates_link(story, string,
                                                next_reprint, from_to, style)
                else:
                    reprint += '<li> ' + esc(string) + ' </li>'

        dt = '<dt class="credit_tag'
        dd = '<dd class="credit_def'
        if (style):
            dt += ' %s' % style
            dd += ' %s' % style
        dt += '">'
        dd += '">'
        
        return mark_safe(dt + '<span class="credit_label">' + _('Reprints') \
                + ':' + '</span></dt>' + \
                dd + '<span class="credit_value"><ul>' + reprint \
                + '</ul></span></dd>')
    else:
        return ""

def parse_reprint(reprints, from_to):
    """ parse a reprint entry for exactly our standard """
    notes = None
    
    if reprints.lower().startswith(from_to):
        try:# our format: seriesname (publisher, year <series>) #nr
            position = reprints.find(' (')
            series = reprints[len(from_to):position]
            # could remove the/The from beginning and from end with ','
            string = reprints[position+2:]
            after_series = string # use in other formats
            end_bracket = string.find(')')
            position = string[:end_bracket].rfind(', ')
            publisher = string[:position].strip()
            position+=2
            string = string[position:]
            year = string[:4]
            if from_to in ['da ', 'in ', 'de ', 'en ']: #italian and spanish from/in
                if year.isdigit() != True:
                    position = string.find(')')
                    year = string[position-4:position]
            string = string[4:]
            position = string.find(' #')+2
            string = string[position:]
            position = string.find(' [') #check for notes
            if position > 0:
                position_end = string.find(']')
                if position_end > position:
                    notes = string[position:position_end+1]
                date_pos = string.find(' (') #check for (date)
                if date_pos > 0 and date_pos < position:
                    position = date_pos
            else:
                position = string.find(' (') #check for (date)
                if position > 0: #if found ignore later
                    pass
            if string.isdigit(): #in this case we are fine
                number = string
            else:
                if position > 0:
                    number = string[:position].strip('., ')
                else:
                    number = string.strip('., ')
            results = Issue.objects.all()
            results = results.filter(series__name__icontains = series)
            results = results.filter(series__publisher__name__icontains 
            = publisher)
            results = results.filter(series__year_began__exact = int(year))
            results = results.filter(number__exact = number)
            if results.count() > 1:
                results = results.filter(series__name__exact = series)
        except:
            pass
        
        return results, notes
    else:
        return Issue.objects.none(), None


def show_reprint(story, style):
    """ Filter for our reprint line."""
    
    reprint_direction = ["from ", "in "]
    if story.issue.series.language_code.lower() == 'it': #da, in
        reprint_direction = ["da "] + reprint_direction
    elif story.issue.series.language_code.lower() == 'es': #de, en
        reprint_direction = ["de ", "en "] + reprint_direction
    elif story.issue.series.language_code.lower() == 'nl': # uit, in
        reprint_direction = ["uit "] + reprint_direction 
    elif story.issue.series.language_code.lower() == 'sv': # från, i
        reprint_direction = [u"från ", "i "] + reprint_direction 
    elif story.issue.series.language_code.lower() == 'de': # aus
        reprint_direction = ["aus "] + reprint_direction 
    if story.reprints:
        reprint = ""
        for string in story.reprints.split(';'):
            string = string.strip()
            for from_to in reprint_direction:
                next_reprint, notes = parse_reprint(string, from_to)
                if next_reprint.count() == 1:
                    reprint += generate_reprint_link(story, next_reprint[0],
                                                     from_to, style,
                                                     notes = notes)
                    break
            if next_reprint.count() != 1:
                reprint += '<li> ' + esc(string) + ' </li>'

        # old version, without linkify button
        #return mark_safe('<dt class="credit_tag">Reprints:</dt>' + \
                         #'<dd class="credit_def"><ul> ' + reprint + \
                         #'</ul></dd>')
        label = _('Reprints') + ': <span class="linkify">' + \
                '<a href="?reprints=True">' + \
                'search and link</a></span>'
    
        dt = '<dt class="credit_tag'
        dd = '<dd class="credit_def'
        if (style):
            dt += ' %s' % style
            dd += ' %s' % style
        dt += '">'
        dd += '">'

        return mark_safe(dt + '<span class="credit_label">' + label + '</span></dt>' + \
               dd + '<span class="credit_value"><ul>' + reprint + '</ul></span></dd>')
    
    else:
        return ""

register.filter(show_reprint)
register.filter(show_reprint_full)
register.filter(show_reprint_suggestions)
