#!/bin/bash
VER=g01
FILE="/home/sec588/.bashrc"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    
if [ "$EUID" = 0 ]
  then echo "Please don't run as root or sudo!"
  exit
fi

function UPDATE_RSAJOIN () {
  curl -o /tmp/rsajoin.sh https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/rsajoin.sh
  if ! cmp --silent "/tmp/rsajoin.sh" "/home/sec588/Coursefiles/SampleScripts/rsajoin.sh"
  then
    mv /tmp/rsajoin.sh /home/sec588/Coursefiles/SampleScripts/rsajoin.sh
    chmod a+x /home/sec588/Coursefiles/SampleScripts/rsajoin.sh
  fi
}

function UPDATE_NGINX () {
  curl -s -o /tmp/nginx-default-site https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/nginx-default-site
  if ! cmp --silent "/tmp/nginx-default-site" "/etc/nginx/sites-enabled/default"
  then
    sudo mv /tmp/nginx-default-site /etc/nginx/sites-enabled/default
    sudo systemctl restart nginx
    echo "[+] Please close and open any web browsers as we have updated the nginx configuration"
  fi
}

function UPDATE_JOHN () {
  # Only for G01
  if [ ! -f /opt/john/john.sh ]
  then
    echo "[+] Fixing John the Ripper"
    curl -s https://media.githubusercontent.com/media/mosesrenegade/sec588-public/master/john.tar.gz --output /tmp/john.tar.gz
    tar -zxf /tmp/john.tar.gz 
    sudo rm /opt/john
    sudo mv john /opt
    sudo chown -R sec588:sec588 /opt/john
    sudo ln -s /opt/john/john.sh /opt/bin/john
    sudo apt remove john -y
  fi
}

function UPDATE_WIKI () {
    curl -s -o /tmp/wiki-update.sh https://raw.githubusercontent.com/mosesrenegade/sec588-public/master/wiki-update.sh
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
    sed -i "s/\$STUDENT/$STUDENT/g" ./*.html
    sed -i "s/\$CLASS/$CLASS/g" ./*.html
    sudo cp -r . /var/www/html/wiki
    UPDATE_JOHN
    UPDATE_NGINX
    UPDATE_RSAJOIN
}

function UPDATE_ENV() {
    if [ -f "$FILE" ]
    then
      if grep -q "CLASS" "$FILE"
      then
          sed -i '/CLASS=/d' $FILE
      fi
      if grep -q "STUDENT" "$FILE"
      then
          sed -i '/STUDENT=/d' $FILE
      fi
      if grep -q "UA" "$FILE"
      then
          sed -i '/UA=/d' $FILE
      fi
    fi
    
    echo "export CLASS=\"$CLASS\"" >> $FILE
    echo "export STUDENT=\"$STUDENT\"" >> $FILE
    echo "export UA=\"$UA\"" >> $FILE
}

function HELP () {
    echo "[+] This course features a quest to update this wiki, you must"
    echo "[+] pass lab 1.5 to update your local wiki! Have fun exploring"
}

function QUESTIONS () {
    echo "[+] What is your class name? It will be found in the MyLabs portal,"
    echo "[+] Look for the targets range domain, example: pickle-orchid.sec588.net."
    read -p "You would enter pickle-orchid in this prompt: " CLASS
 
    read -p "What is your student number? Numbers only please : " STUNUM
    
    STUDENT=student$STUNUM
    UPDATE_ENV
    UPDATE_WIKI
    
    echo "[+] We have added new environment variables you should close all terminal windows and open them!"
}

CLASS=$(if [ -f "$FILE" ]; then cat $FILE | grep CLASS | awk -F= '{ print $2 }' | awk -F\= '{ print $1 }' | sed -e 's/^"//' -e 's/"$//'; fi )
STUDENT=$(if [ -f "$FILE" ]; then cat $FILE | grep STUDENT | awk -F= '{ print $2}' | sed -e 's/^"//' -e 's/"$//'; fi )

if [[ -z "$CLASS" || -z "$STUDENT" ]]
then
    QUESTIONS
else
    echo "[+] Student Number currently set to $STUDENT"
    echo "[+] Class name currently set to $CLASS"
    read -p "Do you need to Update your Student Number or Class Name? [y/N]" UPDATE
    case $UPDATE in 
        [Yy]* ) QUESTIONS;;
        * ) UPDATE_WIKI;;
    esac

fi

