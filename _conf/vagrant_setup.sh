#!/bin/bash
USER_HOME=/home/vagrant
PROJECT_DIR=/home/vagrant/site

##
#	Add/Update the package repositories..
##
add-apt-repository -y ppa:deadsnakes/ppa
apt-get -y update
apt-get -y upgrade

##
#	List the packages to be installed..
##
packagelist=(

	# Install to have common packages installed..
	software-properties-common

	# Install to share folders between vagrant OS and developer OS..
	nfs-common

	# Install python3..
	python3.9
	libpython3.9-dev python3.9-distutils
	build-essential libssl-dev libffi-dev

	# Install pip3 and venv..
	python3-pip
	python3-venv

	# Install the database..
	postgresql

	# Install packages for python package 'psycopg2'..
	python3-dev libpq-dev

	# Install required packages for python package 'pygraphviz' (used by django-extensions to generate graph models)..
	graphviz graphviz-dev pkg-config

)

##
#	Install the packages..
##
apt-get -y install ${packagelist[@]}

##
#	Setup pip3 the virtual environment..
##
pip3 install virtualenv virtualenvwrapper
# Note: pip install --upgrade [package]

##
#	Setup the virtualwrapper by having a script execute the first time the user connects..
##
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
	echo "mkvirtualenv --python=`which python3.9` site" >> ${USER_HOME}/.bashrc
	echo "deactivate" >> ${USER_HOME}/.bashrc
	echo "cd ${USER_HOME}" >> ${USER_HOME}/.bashrc
echo "fi" >> ${USER_HOME}/.bashrc

echo "if [ ! -f ${VIRTUALENVWRAPPER_INSTALLED_FILE} ]; then" >> ${USER_HOME}/.bashrc
	echo "echo \"Installation of virtualenvwrapper completed.\" >> ${VIRTUALENVWRAPPER_INSTALLED_FILE}" >> ${USER_HOME}/.bashrc
echo "fi" >> ${USER_HOME}/.bashrc

##
#	Setup the database..
##
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
