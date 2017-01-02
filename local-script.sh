#!/bin/sh

# install redis for php5
sudo apt-get install -qq php5-redis

# we need to install the mysql command lin client so we can run import commands
sudo apt-get install -qq mysql-client

# BS
#echo "Install mysqlnd driver - this returns data types with data"
#sudo apt-get install -qq php5-mysqlnd


# Local scripts for LiberatedLiving box provisioning
# clone the LiberatedLiving repo

# install the custom apache configuration file.  We'll just symlink to it so it can be changed on the fly
# Just so this passes we remove the symlink if it exists
echo "######## SETTING UP LIBERATEDLIVING APACHE CONF ##############"
APACHE_CONF_FILE=/etc/apache2/sites-enabled/001-liberated-living.conf
if [ -e  $APACHE_CONF_FILE ]
then
	sudo rm $APACHE_CONF_FILE
fi
sudo ln -s /vagrant/conf/liberatedliving-apache2.conf $APACHE_CONF_FILE

echo "######## SETTING UP LIBERATEDLIVING DB ##############"

# DB_IMPORT_URL=https://dl.dropboxusercontent.com/...
#echo "Downloading database snapshot from $DB_IMPORT_URL"
#curl -o $DB_IMPORT_FILE=$DB_IMPORT_FILE


# import the database
# mysqldump -h orbit-development.cb0nvxtqnr3s.us-east-1.rds.amazonaws.com --ssl-ca=/vagrant/conf/rds-combined-ca-bundle.pem --ssl-verify-server-cert -u root --password=5c50af7a5970f88e3628432aa7116596 -e liberatedliving | gzip > /vagrant/conf/liberatedliving.sql.gz
DB_IMPORT_FILE=/vagrant/conf/liberatedliving.sql.gz

if [ -f $DB_IMPORT_FILE ]; then
	TMP_FILE=/tmp/liberatedliving.sql
	TMP_FILE_GZ=$TMP_FILE.gz

	# sudo rm $TMP_FILE
	cp -f $DB_IMPORT_FILE $TMP_FILE_GZ
	gunzip -f $TMP_FILE_GZ

	echo "Importing/overriding liberatedliving DB from $DB_IMPORT_FILE"
	mysql -h 127.0.0.1 -u root --password=root -e "CREATE DATABASE liberatedliving CHARACTER SET utf8 COLLATE utf8_general_ci;"
	mysql -h 127.0.0.1 -u root --password=root liberatedliving < $TMP_FILE
else
	echo "WARNING: local liberatedliving database not loaded - file does not exists"
fi

echo "Setting up LiberatedLiving user"
mysql -h 127.0.0.1 -u root --password=root mysql < /vagrant/conf/grants.sql

echo "Restart apache"
service apache2 restart

echo "######## COPYING LOCAL CONFIG FILES ##############"

AUTOLOAD=/vagrant/sites/liberated-living/config/autoload
# composer install
echo "Copy local config files"
if [ ! -f $AUTOLOAD/database.local.php ]; then
	cp /vagrant/conf/database.local.php $AUTOLOAD;
else
	echo "WARNING: local database config exists, didn't copy the template"
fi
if [ ! -f $AUTOLOAD/mail.config.local.php ]; then
	cp /vagrant/conf/mail.config.local.php $AUTOLOAD;
else
	echo "WARNING: local mail config exists, didn't copy the template"
fi
if [ ! -f $AUTOLOAD/stripe.local.php ]; then
	cp /vagrant/conf/stripe.local.php $AUTOLOAD;
else
	echo "WARNING: local stripe config exists, didn't copy the template"
fi

# BS
# echo "Install GitHub API access token so we don't get bandwidth restriction"
# sudo -s composer config -g github-oauth.github.com bc1d6e6f7a1373b2225438d409f104b42b3954c0

echo "Installing bower, then install from composer, npm and bower in the project folder"
# Note - the way npm is installed this should be run as the vagrant user
sudo su -l vagrant -c "npm install -g bower; cd /vagrant/sites/liberated-living; composer install; npm install; bower install"
