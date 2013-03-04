# django-environment-in-vagrant

Instantly build a clean environment ready for Django development.

## Why does this exist?

There are a variety of reasons why you may find this project useful. To name a few:

1. You want to start developing or learning Django without the hastle of installing an environment.
2. You want to keep your host operating system clean from any development environments.
3. You want to use your favorite editor in the host operating system and synchronize to the development environment.
4. You want a simple skeleton you can trust that is basic enough to read through.
5. You want no clutter involved in your development environment.
6. You are on OS X or Windows and just want to begin developing but do not want to deal with installing a Linux environment, etc.
7. You do not want to deal with Puppet or Chef.

## Getting started

You need to install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](http://www.virtualbox.org/).
If you face any problems, see the [Vagrant documentation](http://www.vagrantup.com/).

## Cloning the repository

Clone this repository as the name of the project you are developing:

	git clone https://github.com/aminehaddad/django-environment-in-vagrant.git my_project

Where `my_project` is the name of your new website or project.

## Building the environment

To build or start the development environment, simply run the following command from within your `my_project` directory:

	vagrant up

This is what will happen:

1. Vagrant will download Ubuntu Precise 32-bit and then create a Virtual Machine.
2. Vagrant will prompt you for your password to setup NFS sharing between the guest and the host.
3. Vagrant will execute the following script in the guest operating system: `_conf/vagrant_setup.sh`.

At this point, `_conf/vagrant_setup.sh` takes over and does the following:

1. It updates the package repositories for Ubuntu.
2. It installs git, nginx, nfs tools, postgresql, and virtualenvwrapper.
3. It configures nginx by symlinking to `_conf/etc/nginx/sites-available/site.conf`
4. It creates the postgres user `vagrant` with password `vagrant`
5. It creates the database `vagrant` and gives the user `vagrant` access to it.
6. It installs virtualenvwrapper.
7. It creates a virtual environment called `vagrant`

That's it! You now have a clean development environment.

## Awesome! What's next?

You need to setup your Django project! Do it like so:

1. SSH into your environment with: `vagrant ssh`
2. CD into your development directory: `cd site`
3. Activate the python virtual environment with: `workon vagrant`
4. Install requirements.txt: `pip install -r requirements.txt`
5. Create a Django project: `django-admin.py startproject my_site .` (pay attention to the . at the end of that command)
6. Run the Django webserver: `python manage.py runserver`
7. Access your site in your host environment by visiting: [http://192.168.31.100](http://192.168.31.100/)

## Wowzers! But won't it commit to your repository instead of mine?

Yes, unfortunately it will. You can fix that in the virtual environment by deleting the `.git` directory and re-initializing it.

If you know of a better way to solve that problem, feel free to let me know!

## Troubleshooting

This section is reserved for common troubleshooting problems or hints.
