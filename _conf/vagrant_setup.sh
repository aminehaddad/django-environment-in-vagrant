#!/bin/bash

PROJECT_DIR=/home/vagrant/site
USER_HOME=/home/vagrant

echo "Environment installation is beginning. This may take a few minutes.."

##
#	Install core components
##

echo "Updating package repositories.."
apt-get update

echo "Installing required packages.."
apt-get -y install git nginx python-pip

echo "Installing required packages for NFS file sharing for vagrant.."
apt-get -y install nfs-common

echo "Installing required packages for postgres.."
apt-get -y install postgresql

echo "Installing required packages for python package 'psycopg2'.."
apt-get -y install python-dev libpq-dev

echo "Installing virtualenvwrapper from pip.."
pip install virtualenvwrapper

##
#	Configure nginx
##
echo "Configuring nginx.."

rm --force /etc/nginx/sites-enabled/*

cd /etc/nginx/sites-available
ln --symbolic --force ${PROJECT_DIR}/_conf/etc/nginx/sites-available/site.conf

cd /etc/nginx/sites-enabled
ln --symbolic --force ../sites-available/site.conf

service nginx restart

##
#	Setup the database
##

echo "Configuring postgres.."
sudo -u postgres psql -c "create user vagrant with password 'vagrant';"
sudo -u postgres psql -c "create database vagrant;"
sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"

##
#	Setup virtualenvwrapper
##
echo "Installing virtualenvwrapper.."
if grep --quiet "virtualenvwrapper.sh" ${USER_HOME}/.bashrc; then
	echo "virtualenvwrapper already installed."
else
	echo "source /usr/local/bin/virtualenvwrapper.sh" >> ${USER_HOME}/.bashrc
fi

##
#	Setup virtualenv
##
echo "Install the virtual environment.."
sudo su - vagrant /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh;cd ${PROJECT_DIR};mkvirtualenv vagrant; deactivate;"

##
#	Setup is complete.
##
echo ""
echo "The environment has been installed."
echo ""
echo "You can start the machine by running: vagrant up"
echo "You can ssh to the machine by running: vagrant ssh"
echo "You can stop the machine by running: vagrant halt"
echo "You can delete the machine by running: vagrant destroy"
echo ""
echo "If this is your first time, you should install the virtual machine guest additions."
echo "To do that, ssh into the machine (vagrant ssh) and run: sudo ./postinstall.sh"
echo ""
exit 0
