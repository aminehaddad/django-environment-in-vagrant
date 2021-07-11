# django-environment-in-vagrant

Quickly build a clean virtual environment ready for Django development.

### Important:

- VirtualBox currently DOES NOT work with Apple's new M1+ processors. Other options to virtualize on M1+ are Parallels, Fusion, and so on.

- When `~/` is shown below, it means your home directory. This doesn't work in Windows unless you install an alternative `shell`. In this tutorial, it's recommended to use `Git Bash` and we'll show you how to install it.

- In Mac, when using the default shell `zsh` command line, run the following command to allow comments using `#` character: `setopt interactivecomments`

### Required packages to install

Install the following applications in your host operating system:

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
* [GitHub Desktop](https://desktop.github.com/)
* [Git](https://git-scm.com/downloads)

You've now installed `shells` in your operation system:

* Git Bash (Windows)
* Terminal (Mac)
* /bin/bash (unix/linux)

Open your `shell` and install [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest):

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin update vagrant-vbguest
```

## Let's get started!

For this tutorial, we will make a project called `my-project` that shows you a landing page.

### Getting the source code

Open your `shell` to create a new project called `my-project`:

```bash
# Create the development directory for all projects (we assume it's just called 'Development')
mkdir -p ~/Development/

# Get source code and put it in `my-project` directory
cd ~/Development/

git clone https://github.com/aminehaddad/django-environment-in-vagrant.git my-project

cd ~/Development/my-project

# Delete the `.git` folder since it belongs to `https://github.com/aminehaddad/django-environment-in-vagrant.git`:
rm -rf ~/Development/my-project/.git/
```

### Starting the virtual machine development environment

The following command will start the environment:

```bash
# Start the virtual machine:
vagrant up

# SSH into the virtual machine:
vagrant ssh
```

### Setting up the virtual machine development environment

After you `vagrant up` and `vagrant ssh`, we'll install required packages in the virtual machine:

```bash
# We work in ~/site/ inside the virtual machine
cd ~/site/

# Always run the following command to use the proper python virtual environment:
workon site

# Install the required python packages (update `pip` first):
pip install --upgrade pip
pip install -r requirements.txt

# See if new versions are available for your packages:
# pip list -o
```

### Setting up your Django project

Create a new Django project called `my_site`:

```bash
cd ~/site/
django-admin startproject my_site .

# We will run `migrations` to update the database:
./manage.py migrate
```

Django requires the IP address of the Virtual Machine in the `my_site/settings.py` file for the setting `ALLOWED_HOSTS`:

```python
ALLOWED_HOSTS = ['10.10.10.10', '127.0.0.1']
```

You can now start the development web server:

```bash
./manage.py runserver 0.0.0.0:8080
```

Access this URL for MacOS/Linux/Windows (unless you modified `Vagrantfile`):

* [http://10.10.10.10:8080](http://10.10.10.10:8080/)

To turn off the virtual machine, run the following from your host terminal:

```bash
vagrant halt
```

To turn on the virtual machine, run the following:

```bash
vagrant up
```

### Creating your first application

We went over the creation of `my-project` and `my_site`. Now, we need to create `apps` to start developing the project and we will call our first app `my_landing`:

```bash
cd ~/site/
./manage.py startapp my_landing
```

### Open an editor to tell the app how to handle requests/responses:

Create and edit the file `my_landing/urls.py` file to add a couple of URLs:

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.landing, name='landing'),
    path('contact/', views.contact, name='contact'),
]
```

Edit the apps `my_landing/views.py` to show how to handle requests and responses for a couple URLs:

```python
from django.shortcuts import render
from django.http import HttpResponse

def landing(request):
    return HttpResponse("This is the landing page.")

def contact(request):
    return HttpResponse("You can contact us by calling 123-456-7890.")
```

Edit the `my_project/urls.py` to tell it to allow `my_landing/urls.py` in the project:

```python
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('', include('my_landing.urls')),
    path('admin/', admin.site.urls),
]
```

You can continue creating more apps and views and so on!

## Continue reading to be able to have production environments.

The changes located in README-PRODUCTION.md.

## Troubleshooting / Q&A

This section is reserved for common troubleshooting problems or hints.

#### Question: How can I change the git repository this is committing to?

Answer: You can fix that in the virtual environment by deleting the `.git` directory and re-initializing it. Example:

```bash
cd ~/Development/my-project/
rm -rf .git
```

#### Question: Running test cases

Add `coverage` package in `requirements.txt`:

```python
# Coverage (for testing)
coverage
```

Install the packages:

```bash
pip install -r requirements.txt
```

Create `~/site/.coveragerc` file:

```
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
```

Run all test cases:

```bash
rm -rf ~/site/_test_results
coverage run ./manage.py test
coverage html
```

Shortcut:

```bash
rm -rf ~/site/_test_results && coverage run ./manage.py test && coverage html
```

It will generate HTML files with all test results. Just find and open the `index.html` to see results.

#### Question: How to make a graph image of the database models?

Modify your `requirements.txt` file:

```python
# Django extensions (for testing).
# Used to generate model graph with command:
# ./manage.py graph_models -a -g -o models.png
django-extensions
pygraphviz
```

Install the packages:

```bash
pip install -r requirements.txt
```

Modify your `my_site/settings.py` file to add it in `INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'django_extensions', # <-- here
]
```

Run the following command to generate a file with the models:

```bash
./manage.py graph_models -a -g -o models-1.png
```

It would be nice to keep history of `models-1.png` and `models-2.py` and `models-3.png` and so on.

#### Question: How to backup and restore database in Vagrant?

To backup database (after `vagrant ssh`), run the following:

```bash
cd ~/site/
sudo -u postgres pg_dump vagrant > db-backup-1.sql
```

To restore database backup, run the following:

```bash
cd ~/site/
sudo -u postgres psql -c "drop database vagrant;"
sudo -u postgres psql -c "create database vagrant;"
sudo -u postgres psql -c "alter role vagrant SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "alter role vagrant SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "alter role vagrant SET timezone TO 'UTC';"
sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"
sudo -u postgres psql vagrant < db-backup-1.sql
```

To import in Vagrant when exported from Heroku:

```bash
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U vagrant -d vagrant heroku-export-1.db
```

#### Question: How to deal with Heroku CLI?

For Windows, download from [Heroku](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)

For Linux/Mac, install Brew on your operating system:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Then, you need to install Heroku CLI on your operating system:

```bash
brew tap heroku/brew && brew install heroku
heroku auth:login
```

It will give you a link to login to Heroku. Afterwards, you can use the `heroku` command.

You can now push to GitHub and Heroku as follows (including going into /bin/bash for Heroku):

```bash
# To GitHub
git push origin
```

```bash
# To Heroku staging (so you can perform test)
git push my-project-staging master
```

```bash
# To Heroku production
git push my-project-production master
```

You can also use the `heroku run` to SSH to your currently running Heroku instance:

```bash
# For staging
heroku run --remote my-project-staging /bin/bash
```

```bash
# For production
heroku run --remote my-project-production /bin/bash
```

#### Question: error "Vagrant was unable to mount VirtualBox shared folders"

To simply solve this, just do the following:

```bash
vagrant up
vagrant ssh
```

Inside the virtual machine, run this command:
```bash
# The fix inside your virtual machine
sudo ln -sf "$lib_path/$PACKAGE/mount.vboxsf" /sbin

# Exit the virtual machine
exit
```

Reboot the virtual machine and connect to it:
```bash
vagrant halt
vagrant up
vagrant ssh
```

You should now be able to see your shared files in `~/site/`.
