from apps.oi import states

SCRIPT_DEBUG = False

def force_old_reservations(user):
    for change in user.changesets.all():
        if change.state == states.OPEN:
            if change.storyrevisions.count():
                change.submit(notes='This is an automatic submit for an '
                  'old reservation from an inactive indexer. The present data '
                  'is from the old OI, it is live in the db, but parts may be '
                  'missing. The submit cannot be sent back to the indexer. If '
                  'the data needs correction please reserve and edit after '
                  'approval. Approval is the default action.')
                print (change, change.id, change.storyrevisions.count())
            else:
                change.discard(user)
                print (change, change.id)


def clear_old_reservations(user):
    if SCRIPT_DEBUG:
        for changeset in user.changesets.filter(state=states.OPEN):
            if changeset.storyrevisions.count():
                print (changeset, changeset.id,
                       changeset.storyrevisions.count())
                return

    for changeset in user.changesets.filter(state=states.OPEN):
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
                print (changeset, changeset.id, revision)
                print ("revision is changed")
                changed = True
        else:
            print changeset, changeset.id
            print ("cover upload") 

        if changeset.storyrevisions.count():
            print "story"
            for story in changeset.storyrevisions.all():
                story.compare_changes()
                if story.is_changed:
                     print (changeset, changeset.id, story)
                     print ("story is changed")
                     changed = True
        if changed:
            changeset.submit(notes='This is an automatic submit for an '
              'old reservation from an inactive indexer. If the change '
              'contains useful information but needs correction please '
              'reserve and edit after approval.')
            print ('http://www.comics.org/changeset/%d/compare/' % 
                   changeset.id)
        else:
            changeset.discard(user,notes='This is an automatic discard of '
              'an unchanged edit by an indexer who was inactive for '
              'three months.')
        print (changeset, changeset.id)

def show_reservations(user):
    for changeset in user.changesets.all():
        if changeset.state==1:
            print (changeset, changeset.id)
            print 'http://www.comics.org/changeset/%d/compare/' % changeset.id


