#!/bin/bash
#Variables
#
user=`pwd | cut -d / -f3 | head -c 8`;
pass=`tr -cd [:alnum:] < /dev/urandom | head -c 12 | xargs -0`;
x=`tr -cd [:alnum:] < /dev/urandom | head -c 3 | xargs -0`;
db="${user}_wp${x}";
y="'${db}'@'localhost'";
files=$(find * -type f -exec chmod 644 {} \;);
dirs=$(find * -type d -exec chmod 755 {} \;);
cpuser=`pwd | cut -d / -f3`;
handler=$(/usr/local/cpanel/bin/rebuild_phpconf --current | awk '($1 ~ /PHP5/){print $3}');
bold=$(tput bold);
norm=$(tput sgr0);
blue=$(tput setav 4);
#
# init
function pause(){
   read -p "$*"
}

# ...
# call it
clear;
echo ' __________________________________________';
echo '|      '${blue} ${bold}'    Wordpress Installer  '${norm}'          |';
echo '|               Version 2.0.1              |';
echo '|                                          |';
echo '|                                          |';
echo '|             By J.Armstrong               |';
echo '|                                          |';
echo '|                                          |';
echo '|__________________________________________|';
pause 'Press [Enter] key to continue...'
# rest of the script
# ...
#
# Download Wordpress to Server
wget --no-check-certificate wordpress.org/latest.tar.gz;

#Extract the compressed file
tar -zxf latest.tar.gz;

#Remove compressed file
rm -rf latest.tar.gz;

#Move Files to rootDir
mv wordpress/* ./;

#Remove extraction directory
rm -rf wordpress/;

#Makes the database for wordpress
/usr/bin/mysqladmin create ${db};

#Make database User
echo "CREATE USER ${db} IDENTIFIED BY '${pass}';" | mysql;

#Grant Privileges to MySQL USER
echo "GRANT ALL PRIVILEGES ON ${db}.* TO ${y} IDENTIFIED BY '${pass}';" | mysql;

#Add db/user to cPanel
/scripts/update_db_cache;
/usr/local/cpanel/bin/dbmaptool ${cpuser} --type mysql --dbs ${db} --dbusers ${db};

#Change ownership
chown -R $cpuser. *;

#clear screen
clear;

#Php handler
echo ;
echo -e ${bold} '!! Your PHP Handler is' $handler '!!' ${norm};
echo '-------------------------------';
#Handler Inquiry
read -p "Is the server running suphp? (y/n)" CONT
if [ "$CONT" == "y" ]; then
  clear;
  echo $dirs;
  echo $files;
  echo "Installation Complete!";
else
  clear;
  echo "Installation Complete!";
fi;

#show credentials
echo ;
echo '----------------';
echo 'COPY THIS FOR WP';
echo '----------------';
echo ;
echo 'db_user:' ${db};
echo ;
echo 'db_name:' ${db};
echo ;
echo 'db_pass:' ${pass};
echo ;
echo 'db_host: localhost';
echo ;
echo '----------------';
echo ;
