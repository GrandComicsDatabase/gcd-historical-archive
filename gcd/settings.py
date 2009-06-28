# Django settings for gcd project.
import sys
from os.path import abspath, dirname, join

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    # ('Your Name', 'your_email@domain.com'),
)

MANAGERS = ADMINS

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'gd=5*w_#ab2z1t#ckcoq!sdvo2s1)96)fb$ii*sh_9w72abhs6'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.load_template_source',
    'django.template.loaders.app_directories.load_template_source',
#     'django.template.loaders.eggs.load_template_source',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
)

ROOT_URLCONF = 'gcd.urls'

MEDIA_ROOT = abspath(join(dirname(__file__), 'media'))
ADMIN_MEDIA_PREFIX = '/media/'

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com", "http://example.com/media/"
MEDIA_URL = "/site_media/"

TEMPLATE_DIRS = ( abspath(join(dirname(__file__), 'templates')), )

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.admin',
    'gcd.core',
    'gcd.migration',
)

# The local settings file has the settings that must be changed for most
# installations, as opposed to this file which should only need to be
# changed by developers.

try:
    import settings_local
    from settings_local import *
except ImportError:
    sys.stderr.write('Unable to read settings_local.py.')
    sys.exit(-1)

