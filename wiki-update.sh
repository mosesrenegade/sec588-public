#!/bin/bash

function UPDATE_WIKI () {
    curl -o /tmp/wiki-updater.sh https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/wiki-update.sh
    sha256sum /opt/wiki/wiki-update.sh | awk '{ print $1 }' > /opt/wiki/wiki-update.sh.sha256
    sha256sum /tmp/wiki-update.sh | awk '{ print $1 }' > /tmp/wiki-update.sh.sha256
    if ! cmp --silent "/opt/wiki/wiki-update.sh.sha256" "/tmp/wiki-update.sh.sha256"
    then
      cp /opt/wiki/wiki-update.sh /opt/wiki/wiki-update.old
      mv /tmp/wiki-update.sh /opt/wiki/wiki-update.sh
      chmod a+x /opt/wiki/wiki-update.sh
      echo "We have had an update to the updater, we are exiting and will require you to RERUN the application"
      exit 1
    fi
    cd /opt/wiki/sec588-labs-e01
    git reset --hard
    git pull
    sudo cp -r . /var/www/html/wiki
}

function UPDATE_ENV() {
    FILE="/home/sec588/.bashrc"
    if grep -q "CLASS" "$FILE"
    then
        C_OLD=$(grep "CLASS" $FILE)
        echo $C_OLD
        sed -i "s/$C_OLD/export CLASS=\"$CLASS\"/g" $FILE 
    fi
    if grep -q "STUDENT" "$FILE"
    then
        S_OLD=$(grep "STUDENT" $FILE)
        echo $S_OLD
        sed -i "s/$S_OLD/export STUDENT=\"student$STUDENT\"/g" $FILE 
    fi
    echo "export CLASS=\"$CLASS\"" >> ~/.bashrc
    echo "export STUDENT=\"student$STUDENT\"" >> ~/.bashrc
}

function HELP () {
    echo "This course features a quest to update this wiki, you must"
    echo "pass lab 1.5 to update your local wiki! Have fun exploring"
}

echo "Have you done Lab 1.5 yet?"
select yn in "Yes" "No"; do
    case $yn in
        [Yy]* ) UPDATE_WIKI;break;;
        [Nn]* ) HELP; exit;;
        * ) "Please answer yes or no.";;
    esac
done

read -p 'What is your class name? It will be found in the MyLabs portal: ' CLASS
read -p 'What is your student number? ' STUDENT
UPDATE_ENV

echo "We have added new environment variables you should close all terminal windows and open them!"
