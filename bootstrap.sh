#!/usr/bin/env bash

apt-get update

# Install Apache
apt-get install -y apache2

# Overwrite the default Apache vhost with one for Storage Manager
rm -rf /etc/apache2/sites-enabled/000-default.conf
ln -fs /vagrant/default-vhost /etc/apache2/sites-enabled/000-default.conf 

# Install Mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password storagemanager'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password storagemanager'
apt-get install -y mysql-server 

# Installing PHP 
apt-get -y install php5 php5-ldap php5-mysql libapache2-mod-php5

# Enable Apache mod_rewrite
a2enmod rewrite

apt-get install sendmail

# Restart Apache just to make sure it picks up all the installed PHP modules and mod_rewrite
service apache2 restart

# Create the database
cat /vagrant/sm_database_create.sql | mysql -u root -pstoragemanager

if [[ $?  -eq 0 ]]
then
   echo "storage_manager database successfully created"
else
   echo "storage_manager database creation failed"
   echo "Exiting"
   exit 2
fi

# Populate the database
cat /vagrant/sm_database_dump-2017-02-13/storage_manager.sql | mysql -u root -pstoragemanager storage_manager

if [[ $?  -eq 0 ]]
then
   echo "storage_manager database successfully populated"
else
   echo "storage_manager database population failed"
   echo "Exiting"
   exit 3
fi

