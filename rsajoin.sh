#!/bin/bash
rm -Rf /home/sec588/Coursefiles/workdir/foundssh-key
sed -e "s/-----BEGIN OPENSSH PRIVATE KEY-----/&\n/"\
    -e "s/-----END OPENSSH PRIVATE KEY-----/\n&/"\
    -e "s/\S\{64\}/&\n/g"\
    /home/sec588/Coursefiles/workdir/foundssh-key-oneline > /home/sec588/Coursefiles/workdir/foundssh-key
chmod 600 /home/sec588/Coursefiles/workdir/foundssh-key

