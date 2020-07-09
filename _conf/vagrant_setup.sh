#!/bin/bash

USER_HOME=/home/vagrant
PROJECT_DIR=/home/vagrant/site

##
#	Updating repositories..
##
echo "Updating package repositories.."
apt-get -y update
apt-get -y upgrade

##
#	Setup to share folders between vagrant OS and developer OS
##
echo "Installing required packages for NFS file sharing for vagrant.."
apt-get -y install nfs-common

##
#	Setup python3..
##
echo "Installing required packages for python3.."
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get -y install python3.8
apt-get -y install libpython3.8-dev
apt-get -y install build-essential libssl-dev libffi-dev

##
#	Setup pip3, and the security tools with it..
##
echo "Installing and setting up pip3.."
apt-get -y install python3-pip
apt-get -y install python3-venv

echo "Setup pip3 environments.."
pip3 install virtualenv virtualenvwrapper

VIRTUALENVWRAPPER_INSTALLED_FILE=${USER_HOME}/.virtualenvwrapper_installed
echo "" >> ${USER_HOME}/.bashrc
echo "VIRTUALENVWRAPPER_INSTALLED_FILE=${VIRTUALENVWRAPPER_INSTALLED_FILE}" >> ${USER_HOME}/.bashrc

echo "export WORKON_HOME=${USER_HOME}/.virtualenvs" >> ${USER_HOME}/.bashrc
echo "export PROJECT_HOME=${USER_HOME}/.projects" >> ${USER_HOME}/.bashrc
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ${USER_HOME}/.bashrc
echo "export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh" >> ${USER_HOME}/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ${USER_HOME}/.bashrc

echo "if [ ! -f ${VIRTUALENVWRAPPER_INSTALLED_FILE} ]; then" >> ${USER_HOME}/.bashrc
	echo "cd ${PROJECT_DIR}" >> ${USER_HOME}/.bashrc
	echo "mkvirtualenv --python=`which python3.8` site" >> ${USER_HOME}/.bashrc
	echo "deactivate" >> ${USER_HOME}/.bashrc
	echo "cd ${USER_HOME}" >> ${USER_HOME}/.bashrc
echo "fi" >> ${USER_HOME}/.bashrc

echo "if [ ! -f ${VIRTUALENVWRAPPER_INSTALLED_FILE} ]; then" >> ${USER_HOME}/.bashrc
	echo "echo \"Installation of virtualenvwrapper completed.\" >> ${VIRTUALENVWRAPPER_INSTALLED_FILE}" >> ${USER_HOME}/.bashrc
echo "fi" >> ${USER_HOME}/.bashrc

##
#	Setup the database
##
echo "Installing required packages for postgres.."
apt-get -y install postgresql

echo "Installing required packages for python package 'psycopg2'.."
apt-get -y install python3-dev libpq-dev

echo "Installing required packages for python package 'pygraphviz' (used by django-extensions to generate graph models).."
apt-get -y install graphviz graphviz-dev pkg-config

echo "Configuring postgres.."
sudo -u postgres psql -c "create user vagrant with password 'vagrant';"
sudo -u postgres psql -c "create database vagrant;"
sudo -u postgres psql -c "alter role vagrant SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "alter role vagrant SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "alter role vagrant SET timezone TO 'UTC';"
sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"

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
exit 0
