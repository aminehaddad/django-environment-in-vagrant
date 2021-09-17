# Setup project to use local/staging/production

This will guide you to create multiple environments with different variables.

These will be the available settings files: `base.py`, `dev.py`, `test.py`, `local.py`, and `heroku.py`.

Note: `heroku.py` is used in this README.py, but you can use another provider.

### Important: you can generate a new `SECRET_KEY` (in console) when necessary using this command:

```python
python -c 'import random; print("".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)]))'
```

### Create and modify multiple `requirements.txt` files

Modify the file `~/site/requirements.txt`:

```bash
# requirements.txt is necessary for Heroku
-r requirements-heroku.txt
```

Created the file `~/site/requirements-base.txt`:

```python
# Install Django
Django==3.2.7

# Required for Django timezones.
pytz==2021.1

# Postgres Database Adapter (requires 'python3-dev' and 'libpq-dev' packages in Ubuntu)
psycopg2==2.9.1

# Database config loader
dj-database-url==0.5.0

# Used for serving static files (for now)
dj-static==0.0.6
```

Create the file `~/site/requirements-heroku.txt`:

```python
# Install base packages
-r requirements-base.txt

# (Heroku) Python WSGI HTTP server.
gunicorn==20.1.0
gevent==21.8.0
```

Create the file `~/site/requirements-dev.txt`:

```python
# Install base packages
-r requirements-base.txt

# Coverage (for testing)
coverage==5.5

# Django extensions (for testing).
# Used to generate model graph with command:
# ./manage.py graph_models -a -g -o models.png
django-extensions==3.1.3
pygraphviz==1.7

# Django Debug Toolbar (for queries)
django-debug-toolbar==3.2.2
```

### In `~/site/my_site/`, we'll put multiple environment settings files (quick commands)

#### Step 1: Create settings files for different environments:

```bash
# Create a folder called `~/site/my_site/settings/`
mkdir -p ~/site/my_site/settings/

# Move `~/my_site/settings.py` to `~/my_site/settings/base.py`
mv ~/site/my_site/settings.py ~/site/my_site/settings/base.py 2>/dev/null
```

#### Step 2: Create `get_env_variable` function in `~/site/my_site/settings/base.py` (in the top):

```python
from django.core.exceptions import ImproperlyConfigured

def get_env_variable(var_name, default=None, required_from_environment=False):
    """
    Returns the environment variable 'var_name'.

    If 'required_from_environment' is False and 'var_name' is not available in environment, returns 'default'.
    If 'required_from_environment' is True and 'var_name' is not available in environment, raises ImproperlyConfigured exception.
    """
    try:
        return os.environ[var_name]
    except KeyError:
        if required_from_environment:
            error_msg = "Set the {0} environment variable".format(var_name)
            raise ImproperlyConfigured(error_msg)
        else:
            return default
```

A few sample on how you can use it (don't add them now):

```python
# Force SECRET_KEY to be set
SECRET_KEY = get_env_variable('SECRET_KEY', required_from_environment=True)

# Django's admin (turn value into True/False)
DJANGO_ADMIN_ENABLED = True if get_env_variable('DJANGO_ADMIN_ENABLED', False) else False

# Google Analytics settings (default is None)
GOOGLE_ANALYTICS_KEY = get_env_variable('GOOGLE_ANALYTICS_KEY', None)

# Facebook SDK settings (default is None)
FACEBOOK_APP_ID = get_env_variable('FACEBOOK_APP_ID', None)
```

#### Step 3: Delete all of these lines in `~/site/my_site/settings/base.py` (they will appear later):

```python
SECRET_KEY
DEBUG
ALLOWED_HOSTS
DATABASES
```

#### Step 4: Create `~/site/my_site/settings/dev.py`:

```python
from .base import *
import dj_database_url

# Django settings
DEBUG = True
ALLOWED_HOSTS = ['*']

# Note: generate a new SECRET_KEY for each project (see FAQ, or below, on how to generate key). Do need to commit it after creation.
SECRET_KEY = 'abcdefghijklmnopqrstuvwxyz0123456789'

# Database settings
DATABASES = {
    'default': dj_database_url.config(default='postgres://vagrant:vagrant@127.0.0.1/vagrant'),
}

# Enable the /admin/
DJANGO_ADMIN_ENABLED = True

# Enable the django-extensions app to generate models.png
INSTALLED_APPS += [
    'django_extensions',
]

GRAPH_MODELS = {
    # Defaults:
    'all_applications': True,
    'group_models': True,

    # Options:
    # 'verbose_names': True,
    # 'json': True,
    # 'disable_fields': True,

    'include_models': ','.join([
    ]),

    'exclude_models': ','.join([
        # Remove Django's defaults
        'LogEntry',
        'AbstractUser',
        'AbstractBaseSession',
        'Session',

        # To exclude 'ContentType', 'Permission', and 'Group': you need to add their fields to exclude_columns
        'ContentType',
        'Permission',
        'Group',

        # Remove some abstract models
        # 'TimestampedModel',
        # 'RandomUUIDModel',
        # 'SoftDeleteModel',

        # Remove the 'User' model (needs 'user' in exclude_columns)
        # 'User',
    ]),

    'exclude_columns': ','.join([
        # These need to be removed to exclude models in exclude_models
        'content_type',
        'user_permissions',
        'permissions',
        'groups',

        # These need to be removed to exclude the User model
        # 'user',
    ]),
}

# This LOGGING outputs queries in console.
# LOGGING = {
#     'version': 1,
#     'filters': {
#         'require_debug_true': {
#             '()': 'django.utils.log.RequireDebugTrue',
#         }
#     },
#     'handlers': {
#         'console': {
#             'level': 'DEBUG',
#             'filters': ['require_debug_true'],
#             'class': 'logging.StreamHandler',
#         }
#     },
#     'loggers': {
#         'django.db.backends': {
#             'level': 'DEBUG',
#             'handlers': ['console'],
#         }
#     }
# }
```

#### Step 5: Generate a new `SECRET_KEY` for `~/site/my_site/settings/dev.py` (in console)

```python
python -c 'import random; print("".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)]))'
```

#### Step 6: Create `~/site/my_site/settings/heroku.py`:

```python
from .base import *
import dj_database_url

# Django settings
DEBUG = True if get_env_variable('DJANGO_DEBUG', False) else False
SECRET_KEY = get_env_variable('SECRET_KEY', required_from_environment=True)

ALLOWED_HOSTS_IMPORT = get_env_variable('ALLOWED_HOSTS_IMPORT', required_from_environment=True)
ALLOWED_HOSTS = ALLOWED_HOSTS_IMPORT.split(',')

# Database settings
DATABASE_URL = get_env_variable('DATABASE_URL', required_from_environment=True)
DATABASES = {
    'default': dj_database_url.config(env='DATABASE_URL'),
}
CONN_MAX_AGE = int(get_env_variable('CONN_MAX_AGE', '0'))

# Honor the 'X-Forwarded-Proto' header for request.is_secure()
# From https://devcenter.heroku.com/articles/getting-started-with-django
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Redirect HTTP to HTTPS
SECURE_SSL_REDIRECT = True if get_env_variable('SECURE_SSL_REDIRECT', False) else False

# Only allow cookies over SSL
SESSION_COOKIE_SECURE = True if get_env_variable('SESSION_COOKIE_SECURE', False) else False
CSRF_COOKIE_SECURE = True if get_env_variable('CSRF_COOKIE_SECURE', False) else False
SESSION_COOKIE_AGE = int(get_env_variable('SESSION_COOKIE_AGE', '1209600'))

# Expire login sessions when the 'browser' closes
SESSION_EXPIRE_AT_BROWSER_CLOSE = True if get_env_variable('SESSION_EXPIRE_AT_BROWSER_CLOSE', False) else False

# Static files settings
STATIC_ROOT = os.path.join(BASE_DIR, '../staticfiles')

# Show exceptions in console
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': get_env_variable('DJANGO_LOG_LEVEL', 'ERROR'),
        },
    },
}
```

NOTE: Create a Heroku app on their website prior to hosting there. If you already created your Heroku program, these are settings you need to add to both your Heroku app and modify `~/site/my_site/settings/heroku.py` to read them.

These settings are needed in your `Heroku` app's settings to match the ones above:

```
ALLOWED_HOSTS_IMPORT = my-project-staging.herokuapp.com
CONN_MAX_AGE = 600
CSRF_COOKIE_SECURE = True
DATABASE_URL = (generated by Heroku or you can point it elsewhere like AWS)
DJANGO_ADMIN_ENABLED = True
DJANGO_DEBUG = 
DJANGO_SETTINGS_MODULE = my_site.settings.heroku
SECRET_KEY = (generate a new SECRET_KEY just for hosting here, see below)
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
SESSION_EXPIRE_AT_BROWSER_CLOSE = True
```

1. Don't forget to generate a new SECRET_KEY and to put it in Heroku.

2. DJANGO_DEBUG must have 0 characters to mean FALSE.

#### Step 7: Create `~/site/my_site/settings/local.py` (and commit the following, but only ONCE to warn other users to not commit their local changes to all developers):

```python
# NOTE: DO NOT COMMIT LOCAL.PY. You can add your changes here for local development (this extends dev.py so you can overwrite stuff from there but DO NOT COMMIT!)
from .dev import *

# .. your custom local development settings here
```

#### Step 8: Create `~/site/my_site/settings/test.py`:

```python
from .base import *

# Note: generate a new SECRET_KEY for each project (see FAQ, or above, on how to generate key). Do need to commit it after creation.
SECRET_KEY = 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmn'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
        'USER': '',
        'PASSWORD': '',
        'HOST': '',
        'PORT': '',
    }
}
```

#### Step 9: Generate a new `SECRET_KEY` for `~/site/my_site/settings/test.py` (in console):

```python
python -c 'import random; print("".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)]))'
```

#### Step 10: Go to `~/site/my_site/urls.py` and modify it to support the `settings.DJANGO_ADMIN_ENABLED`:

```python
from django.contrib import admin
from django.urls import path
from django.conf import settings

urlpatterns = []

if settings.DJANGO_ADMIN_ENABLED:
    urlpatterns += [
        path('admin/', admin.site.urls),
    ]

# You should also add other apps in `urls.py` and point to their `urls.py`:
urlpatterns += [
    path('', include('my_landing.urls')),
]
```

#### Step 11: In `~/site/manage.py` and `~/site/my_site/wsgi.py` and `~/site/my_site/asgi.py`, modify `DJANGO_SETTINGS_MODULE` to aim for the settings file `my_site.settings/local.py`:

```python
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "my_site.settings.local")
```

#### Step 12: Install requirements for dev and Heroku.

Install the packages:

```bash
pip install -r requirements-dev.txt
pip install -r requirements-heroku.txt
```

Heroku does not use requirements-dev.txt. We install the tools for development.

#### Step 13: Run migrations

```bash
# We will run `migrations` to update the database:
./manage.py migrate
```

#### Step 14: Create `~/site/Procfile` for Heroku:

```txt
release: python manage.py migrate
web: gunicorn my_site.wsgi:application -k gevent -w 4
```

#### Step 15: Create `runtime.txt` for Heroku:

```python
python-3.9.6
```

Note: the `runtime.txt` file should NOT have a newline. It tells Heroku which python version to use.
