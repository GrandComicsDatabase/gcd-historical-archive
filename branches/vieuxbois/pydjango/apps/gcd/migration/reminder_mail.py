from django.conf import settings
from django.core import mail
from django.contrib.auth.models import *
from django.db.models import F, Count
from datetime import datetime

user_annotate = User.objects.annotate(changeset_count=Count('changesets'))
inactive_users = user_annotate.exclude(changeset_count=0)
inactive_users = inactive_users.filter(last_login__lt=datetime(2009,12,04,0,0), 
                                       email__contains='@',
                                       indexer__is_banned=False,
                                       indexer__deceased=False,
                                       is_active=True)

# This is just to get the connection.  The non-method "get_connection" function
# shown in the documentation does not actually exist in the module.
email = mail.EmailMessage('Starting...', from_email='sysadmin@comics.org',
                          to=['gcdmail@garcke.de'],
                          headers={'Reply-To': 'gcd-contact@googlegroups.com'})
email.send()

reminder_message="""
Hello from the Grand Comics Database!

This is a reminder email that our new Online Indexing data entry system is 
available for use.  Note that we transfered all reservation from our old 
system.  Due to this you have some reservations from the old system present
in the new one.  You can access them at:

http://www.comics.org/queues/editing

If you are still interested in contributing to the GCD please visit 
http://www.comics.org/ to see a list of features and get started entering 
data and making corrections.

Once you log in to the site, you can edit anything from its display page, or
add series, brands or indicia publishers from the parent publisher page,
or add issues from the issue's series page.

To see the list of changes you have saved but not yet submitted, go to your 
profile (using the "Profile" link in the search bar, or by clicking your own 
name in the login box on the front page) and you will see a gray bar under 
the normal blue search bar.  This has links for adding and editing, as well 
as "pending", which shows submitted changes while they are being reviewed by 
our Editors.

We look forward to your contributions!

Note that if you do not log into our system until mid of February your 
reservations will be discarded.

thanks,
-The Grand Comics Database Team
"""

for old_user in inactive_users:
    email = mail.EmailMessage('Reservations in GCD Online Indexing!',
                              reminder_message,
                              settings.EMAIL_INDEXING,
                              [old_user.email],
                              headers={'Reply-To': settings.EMAIL_CONTACT})
    email.send()

