from django.conf import settings
from django.core import mail
from django.contrib.auth.models import *
from django.db.models import F, Count
from datetime import datetime

user_annotate = User.objects.annotate(changeset_count=Count('changesets'))
inactive_users = user_annotate.exclude(changeset_count=0)

reminder_message="""
Hello from the Grand Comics Database!

This is an automatic reminder email from our Online Indexing data entry 
system.  You you did not log in for more than two months, but have open 
reservations.  You can access them at

http://www.comics.org/queues/editing

If you are still interested in contributing to the GCD please visit 
http://www.comics.org/ to see a list of features and get started entering 
data and making corrections.

We look forward to your contributions!

Note that if you do not log into our system within a month your reservations 
will be discarded to allow the editing by other contributors.

thanks,
-The Grand Comics Database Team
"""

def send_reminder_mail(users):
    for user in users:
        if user.changesets.filter(state=1).count():
            email = mail.EmailMessage('GCD Online Indexing Reminder',
                                      reminder_message,
                                      settings.EMAIL_INDEXING,
                                      [user.email],
                                      headers={'Reply-To': settings.EMAIL_CONTACT})
            print "email sent to %s" % user.indexer
            email.send()

