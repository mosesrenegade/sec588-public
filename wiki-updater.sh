#!/bin/bash

function UPDATE_WIKI () {\
    cp ./wiki-updater.sh /wiki-updater.old
    curl -o ./wiki-updater.sh https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/wiki-updater.sh
    echo "You may have to run this application two times to update the shell script"
    cd /opt/wiki/sec588-labs-e01
    git reset --hard
    git pull
    sudo cp -r . /var/www/html/wiki
}

function HELP () {
    echo "This course features a quest to update this wiki, you must"
    echo "pass lab 1.5 to update your local wiki! Have fun exploring"
}

echo "Have you done Lab 1.5 yet?"
select yn in "Yes" "No"; do
    case $yn in
        [Yy]* ) UPDATE_WIKI; break;;
        [Nn]* ) HELP; exit;;
        * ) "Please answer yes or no.";;
    esac
done

