# django-environment-in-vagrant

Quickly build a clean virtual environment ready for Django development.

## Getting started

Install the following applications in your host operating system:

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

The following Vagrant plugin is recommended to keep the VirtualBox guest additions automatically updated:

* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

This is how you install vagrant-vbguest:

	vagrant plugin install vagrant-vbguest

## Getting the source code

Retrieve the source code:

	git clone https://github.com/aminehaddad/django-environment-in-vagrant.git my-project
	cd my-project

Where `my-project` is the name of your new website or project.

## (Optional) Setting it up for Windows

You need to modify the Vagrantfile if you are running Windows by replacing:

	config.vm.network "private_network", ip: "10.10.10.10"

with:

	config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

## Starting the virtual machine development environment

The following command will start the environment:

	vagrant up

The installation script will run within the virtual machine if it is the first time it is started (in order to install the required packages).

## Setting up the virtual machine development environment

SSH into the virtual machine:

	vagrant ssh

The source code is shared with the virtual machine in this directory:

	cd site

Always run the following command to use the proper python virtual environment:

	workon site

Install the required python packages:

	pip install -r requirements.txt

## Setting up a Django project

Create a new Django project. Pay attention to the `.` at the end of that command if you did `cd site`:

	django-admin.py startproject my_site .

Setup the database models and run migrations:

	./manage.py migrate

You can now start the development web server:

	./manage.py runserver 0.0.0.0:8080

For Windows, replace `./manage.py` with `python manage.py`:

	python manage.py migrate
	python manage.py runserver 0.0.0.0:8080

Django requires the IP address of the Virtual Machine in the `my_site/settings.py` file for the setting `ALLOWED_HOSTS`:

	ALLOWED_HOSTS = ['10.10.10.10', '127.0.0.1']

Access this URL for MacOS/Linux:

* [http://10.10.10.10:8080](http://10.10.10.10:8080/)

Access this URL for Windows:

* [http://127.0.0.1:8080](http://127.0.0.1:8080/)

To turn off the virtual machine, run the following from your host terminal:

	vagrant halt -f

To turn on the virtual machine, run the following:

	vagrant up

## (Optional) Create multiple `requirements.txt` files (supports Heroku as well)

The file `requirements.txt`:

	# requirements.txt is necessary for Heroku
	-r requirements-heroku.txt

The file `requirements-base.py`:

	# Install Django
	Django==3.0.8

	# Required for Django timezones. This is straight from django docs: https://docs.djangoproject.com/en/1.8/topics/i18n/timezones/
	pytz==2020.1

	# Postgres Database Adapter (requires 'python3-dev' and 'libpq-dev' packages in Ubuntu)
	psycopg2

	# Database config loader
	dj-database-url==0.5.0

	# Used for serving static files
	dj-static==0.0.6

The file `requirements-heroku.txt`:

	# Install base packages
	-r requirements-base.txt

	# (Heroku) Python WSGI HTTP server.
	gunicorn==20.0.4
	gevent==20.6.2

The file `requirements-dev.txt`:

	# Install base packages
	-r requirements-base.txt

	# Coverage (for testing)
	coverage==5.1

	# Django extensions (for testing).
	# Used to generate model graph with command:
	# ./manage.py graph_models -a -g -o models.png
	django-extensions==3.0.1
	pygraphviz==1.5

	# Django Debug Toolbar (for queries)
	django-debug-toolbar==2.2

## (Optional) Create multiple `settings.py` files (required for different environments:

Step 1: Temporarily rename `settings.py` to `settings-temp.py`.

Step 2: Create a folder called `settings`.

Step 3: Move back the `settings-temp.py` inside the `settings` folder.

Step 4: Rename `settings-temp.py` to `base.py`.

Step 5: Create `get_env_variable` in `base.py`:

	from django.core.exceptions import ImproperlyConfigured

	def get_env_variable(var_name, default=None, required_from_environment=False):
	'''
	Returns the environment variable 'var_name'.

	If 'required_from_environment' is False and 'var_name' is not available in environment, returns 'default'.
	If 'required_from_environment' is True and 'var_name' is not available in environment, raises ImproperlyConfigured exception.
	'''
	try:
		return os.environ[var_name]
	except KeyError:
		if required_from_environment:
			error_msg = "Set the {0} environment variable".format(var_name)
			raise ImproperlyConfigured(error_msg)
		else:
			return default

Step 6: Add custom environment variables that you want to use using `get_env_variable`:

	# Django's admin
	DJANGO_ADMIN_ENABLED = True if get_env_variable('DJANGO_ADMIN_ENABLED', False) else False

	# Google Analytics settings
	GOOGLE_ANALYTICS_KEY = get_env_variable('GOOGLE_ANALYTICS_KEY', None)

	# Facebook SDK settings
	FACEBOOK_APP_ID = get_env_variable('FACEBOOK_APP_ID', None)

Step 7: Delete all of these lines in `base.py` (they will appear later):

	SECRET_KEY
	DEBUG
	ALLOWED_HOSTS
	DATABASES

Step 8: Create `settings/dev.py`:

	from .base import *
	import dj_database_url

	# Django settings
	DEBUG = True
	SECRET_KEY = 'p1t2bhbws$mjp2*=6mlw&+00k33s4ye2zx%9k#qb(oc*a-%$wt'
	ALLOWED_HOSTS = ['*']

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
			'TimestampedModel',
			'RandomUUIDModel',
			'SoftDeleteModel',

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
	#	 'version': 1,
	#	 'filters': {
	#		 'require_debug_true': {
	#			 '()': 'django.utils.log.RequireDebugTrue',
	#		 }
	#	 },
	#	 'handlers': {
	#		 'console': {
	#			 'level': 'DEBUG',
	#			 'filters': ['require_debug_true'],
	#			 'class': 'logging.StreamHandler',
	#		 }
	#	 },
	#	 'loggers': {
	#		 'django.db.backends': {
	#			 'level': 'DEBUG',
	#			 'handlers': ['console'],
	#		 }
	#	 }
	# }

Step 9: Generate a new `SECRET_KEY` for `settings/dev.py` (in console):

	python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])'

Step 10: Create `settings/heroku.py`:

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

	# Static files should be hashed to prevent problems with cache (and improve cache)
	# STATICFILES_STORAGE = "django.contrib.staticfiles.storage.ManifestStaticFilesStorage"

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

Step 11: Create `settings/local.py` (and commit the following, but only once to warn other users not to commit their local changes to develop):

	# NOTE: DO NOT COMMIT LOCAL.PY. You can add your changes here for local development (this extends dev.py so you can overwrite stuff from there but DO NOT COMMIT!)
	from .dev import *

Step 12: Create `settings/test.py`:

	from .base import *

	SECRET_KEY = '(#7-em@uggczd(&63jeqfxscpk)o1k^v#p)9oofl3i-#v1u(8f'

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

Step 13: Generate a new `SECRET_KEY` for `settings/test.py` (in console):

	python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])'

Step 14: (Optional) Go to `my_site/urls.py` and modify it to support `settings.DJANGO_ADMIN_ENABLED`:

	from django.contrib import admin
	from django.urls import path
	from django.conf import settings

	urlpatterns = []

	if settings.DJANGO_ADMIN_ENABLED:
		urlpatterns += [
			path('admin/', admin.site.urls),
		]

	# Point to other apps in `urls.py`:
	urlpatterns += [
		path('', include('my_landing.urls')),
		path('', include('my_dashboard.urls')),
		path('', include('my_toys.urls')),
	]

Step 15: In `manage.py` and `my_site/wsgi.py` and (untested) `my_site/asgi.py`, modify `DJANGO_SETTINGS_MODULE` to aim for the file `settings/local.py`:

	os.environ.setdefault("DJANGO_SETTINGS_MODULE", "my_site.settings.local")

## (Optional) Create `Procfile` for Heroku:

	release: python manage.py migrate
	web: gunicorn my_site.wsgi:application -k gevent -w 4

## (Optional) Create `runtime.txt` for Heroku:

	python-3.8.3

Note: this should NOT have a newline. It tells Heroku which python version to use.

## Troubleshooting

This section is reserved for common troubleshooting problems or hints.

#### Question: How can I change the git repository this is committing to?

Answer: You can fix that in the virtual environment by deleting the `.git` directory and re-initializing it. Example:

	vagrant ssh
	cd site
	rm -rf .git

#### Running test cases

Create `.coveragerc` first:

	[run]
	omit =
		*/.virtualenvs/*
		*/__init__.py
		*/tests.py
		*/migrations/*
		manage.py
		my_site/*

	[html]
	directory = _test_results

This is how you run all test cases:

	rm -rf _test_results
	coverage run ./manage.py test --settings=my_site.settings.test
	coverage html

Shortcut:

	rm -rf _test_results && coverage run ./manage.py test --settings=my_site.settings.test && coverage html

It will generate HTML files with all test results.

#### Question: How to make a graph image of the database models?

To make an image of database models, run the following:

	./manage.py graph_models -a -g -o models-1.png

#### Question: How to backup and restore database in Vagrant?

To backup database, run the following:

	vagrant ssh
	cd site
	sudo -u postgres pg_dump vagrant > db-backup.sql

To restore database backup, run the following:

	vagrant ssh
	cd site
	sudo -u postgres psql -c "drop database vagrant;"
	sudo -u postgres psql -c "create database vagrant;"
	sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"
	sudo -u postgres psql vagrant < db-backup.sql

#### Question: How to backup and restore database in Vagrant?

To backup database, run the following:

	vagrant ssh
	cd site
	sudo -u postgres pg_dump vagrant > db-backup.sql

To restore database backup, run the following:

	vagrant ssh
	cd site
	sudo -u postgres psql -c "drop database vagrant;"
	sudo -u postgres psql -c "create database vagrant;"
	sudo -u postgres psql -c "alter role vagrant SET client_encoding TO 'utf8';"
	sudo -u postgres psql -c "alter role vagrant SET default_transaction_isolation TO 'read committed';"
	sudo -u postgres psql -c "alter role vagrant SET timezone TO 'UTC';"
	sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"
	sudo -u postgres psql vagrant < db-backup.sql

To import in Vagrant when exported from Heroku:

	pg_restore --verbose --clean --no-acl --no-owner -h localhost -U vagrant -d vagrant heroku-export.db

#### Question: How to deal with Heroku CLI?

First, you need to install Brew:

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

Then, you need to install Heroku CLI:

	brew tap heroku/brew && brew install heroku
	heroku auth:login

It will give you a link to login to Heroku. Afterwards, you can use the 'heroku' commands.

You can now push to GitHub and Heroku as follows (including going into /bin/bash for Heroku):

	git push origin

	git push my-site-staging master
	heroku run --remote my-site-staging /bin/bash

	git push my-site-production master
	heroku run --remote my-site-production /bin/bash
