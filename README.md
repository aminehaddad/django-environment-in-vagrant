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

	git clone https://github.com/aminehaddad/django-environment-in-vagrant.git my_project
	cd my_project

Where `my_project` is the name of your new website or project.

## Starting the virtual machine development environment

The following command will start the environment:

	vagrant up

The installation script will run within the virtual machine if it is the first time it is started (in order to install the required packages).

## Setting up the virtual machine development environment

SSH into the virtual machine:

	vagrant ssh

The source code is shared with the virtual machine in this directory:

	cd site

You can pull the latest source code:

	git pull

Always run the following command to use the proper python virtual environment:

	workon site

Install the required python packages:

	pip install -r requirements.txt

## Setting up a Django project

Create a new Django project:

	`django-admin.py startproject my_site .` (pay attention to the . at the end of that command)

Setup the database models and, if used, run migrations:

	./manage.py syncdb
	./manage.py migrate

You can now start the development web server:

	./manage.py runserver 0.0.0.0:8080

Access this URL:

	[http://10.10.10.10:8080](http://10.10.10.10:8080/)

To turn off the virtual machine, run the following from your host terminal:

	vagrant halt -f

To turn on the virtual machine, run the following:

	vagrant up

## Troubleshooting

This section is reserved for common troubleshooting problems or hints.
