from apps.oi import states
from apps.oi.models import *
from datetime import datetime, timedelta

SCRIPT_DEBUG = False

def force_old_reservations(changes):
    for change in changes:
            if change.storyrevisions.count():
                change.submit(notes='This is an automatic submit for an '
                  'old and inactive reservation. IMPORTANT: The present data '
                  'is from the old OI, it is live in the db, but parts may be '
                  'missing. If the data needs corrections please reserve and '
                  'edit after approval. Approval is the default action.')
                print (change, change.id, change.storyrevisions.count())
            else:
                change.discard(change.indexer)
                print (change, change.id)


def clear_reservations_nine_weeks():
    clearing_date = datetime.today()-timedelta(weeks=9)
    changes = Changeset.objects.filter(created__lt=clearing_date, 
                                       state=states.OPEN)\
                               .exclude(change_type=CTYPES['cover'])
    clear_reservations(changes)
    
def clear_old_reservations(user):
    if SCRIPT_DEBUG:
        for changeset in user.changesets.filter(state=states.OPEN):
            if changeset.storyrevisions.count():
                print (changeset, changeset.id,
                       changeset.storyrevisions.count())
                return
    clear_reservations(user.changesets.filter(state=states.OPEN))

def clear_reservations(changes):
    for changeset in changes:
        changed = False
        if changeset.inline():
            revision = changeset.inline_revision()
        elif changeset.issuerevisions.count() > 0:
            revision = changeset.issuerevisions.all()[0]
        else:
            raise NotImplementedError

        if changeset.coverrevisions.count() == 0:
            revision.compare_changes()
            if revision.is_changed:
                # print (changeset, changeset.id, revision)
                # print ("revision is changed")
                changed = True
        else:
            # print changeset, changeset.id
            print ("cover upload") 

        if changeset.storyrevisions.count():
            # print "story"
            for story in changeset.storyrevisions.all():
                story.compare_changes()
                if story.is_changed:
                     # print (changeset, changeset.id, story)
                     # print ("story is changed")
                     changed = True
	if not SCRIPT_DEBUG:
            if changed:
                changeset.submit(notes='This is an automatic submit for an '
                  'old reservation. If the change contains useful information '
                  'but needs correction please reserve and edit after approval.')
                print ('http://www.comics.org/changeset/%d/compare/' % 
                       changeset.id)
            else:
                changeset.discard(changeset.indexer,notes='This is an automatic discard of '
                  'an unchanged edit which was reserved for 9 weeks')
        print (changeset, changeset.id, changed, changeset.created)

def show_reservations(user):
    for changeset in user.changesets.all():
        if changeset.state==1:
            print (changeset, changeset.id)
            print 'http://www.comics.org/changeset/%d/compare/' % changeset.id


