#!/bin/bash
VER=g01

function UPDATE_WIKI () {
    curl -o /tmp/wiki-update.sh https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/wiki-update.sh
    if ! cmp --silent "/tmp/wiki-update.sh" "/opt/wiki/wiki-update.sh"
    then
      mv /opt/wiki/wiki-update.sh /opt/wiki/wiki-update.old
      mv /tmp/wiki-update.sh /opt/wiki/wiki-update.sh
      chmod a+x /opt/wiki/wiki-update.sh
      echo "We have had an update to the updater, we are exiting and will require you to RERUN the application"
      exit 1
    fi
    cd /opt/wiki/sec588-labs-$VER
    rm -Rf *.html
    git reset --hard
    git pull
    sed -i "s/\$STUDENT/student$STUDENT/g" ./*.html
    sed -i "s/\$CLASS/$CLASS/g" ./*.html
    sudo cp -r . /var/www/html/wiki
}

function UPDATE_ENV() {
    FILE="/home/sec588/.bashrc"
    if grep -q "CLASS" "$FILE"
    then
        sed -i '/CLASS=/d' $FILE
    fi
    if grep -q "STUDENT" "$FILE"
    then
        sed -i '/STUDENT=/d' $FILE
    fi
    echo "export CLASS=\"$CLASS\"" >> ~/.bashrc
    echo "export STUDENT=\"student$STUDENT\"" >> ~/.bashrc
}

function HELP () {
    echo "This course features a quest to update this wiki, you must"
    echo "pass lab 1.5 to update your local wiki! Have fun exploring"
}

echo "What is your class name? It will be found in the MyLabs portal,"
echo "for example if your WIKI URL is http://wiki.first-name.sec588.net "
read -p "then your class name is first-name : " CLASS

read -p "What is your student number? " STUDENT
UPDATE_ENV
UPDATE_WIKI

echo "We have added new environment variables you should close all terminal windows and open them!"
