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
    SSH_CONFIG="/home/sec588/.ssh/config"
    if grep -q "  #IdentityFile ~/.ssh/sec588-wiki-vm-keys" "$SSH_CONFIG"
    then
        sed -i "s/  #IdentityFile ~\/.ssh\/sec588-wiki-vm-keys/  IdentityFile ~\/.ssh\/sec588-wiki-vm-keys/g" "$SSH_CONFIG"
    fi
    if grep -q "  IdentityFile /home/sec588/.ssh/day4" "$SSH_CONFIG"
    then
        sed -i "s/  IdentityFile \/home\/sec588\/.ssh\/day4/  #IdentityFile \/home\/sec588\/.ssh\/day4/g" "$SSH_CONFIG"
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
    UA='"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"'
    if grep -q "CLASS" "$FILE"
    then
        sed -i '/CLASS=/d' $FILE
    fi
    if grep -q "STUDENT" "$FILE"
    then
        sed -i '/STUDENT=/d' $FILE
    fi
    if ! grep -q "UA=" "$FILE"
    then
        echo 'UA=$UA' "$FILE" 
    fi
    echo "export CLASS=\"$CLASS\"" >> ~/.bashrc
    echo "export STUDENT=\"student$STUDENT\"" >> ~/.bashrc
}

function HELP () {
    echo "This course features a quest to update this wiki, you must"
    echo "pass lab 1.5 to update your local wiki! Have fun exploring"
}

function QUESTIONS() {
    echo "What is your class name? It will be found in the MyLabs portal,"
    echo "for example if your WIKI URL is http://wiki.first-name.sec588.net "
    read -p "then your class name is first-name : " CLASS
 
    read -p "What is your student number? Numbers only please : " STUDENT
    UPDATE_ENV
    UPDATE_WIKI
    
    echo "We have added new environment variables you should close all terminal windows and open them!"
}

while true; do
    read -p "Do you need to Update your Student Number or Class Name? [Y/N]" UPDATE
    case $UPDATE in 
        [Yy]* ) QUESTIONS;;
        [Nn]* ) UPDATE_WIKI;;
        * ) echo "Please answer Y or N.";;
    esac
done

echo "Updated"
