#!/bin/bash

if [ -n "$VNC_PW" ]; then
    echo -n "$VNC_PW" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/supervisord.conf
fi

if [ -n "$VNC_RESOLUTION" ]; then
    sed -i "s|%VNC_RESOLUTION%|$VNC_RESOLUTION|" /etc/supervisor/supervisord.conf
fi
if [ -n "$VNC_COL_DEPTH" ]; then
    sed -i "s|%VNC_COL_DEPTH%|$VNC_COL_DEPTH|" /etc/supervisor/supervisord.conf
fi

USER=${USER:-root}
HOME=/root
if [ "$USER_NAME" != "root" ]; then
USER=$USER_NAME
    echo "* enable custom user: $USER"

    useradd --create-home --shell /bin/bash --user-group --groups adm,wheel $USER -u $USER_ID
    if [ -z "$VNC_PW" ]; then
        echo "  set default password to \"ubuntu\""
        VNC_PW=password
    fi
    HOME=/home/$USER
    echo "$USER:$VNC_PW" | chpasswd
fi
sed -i "s|%USER%|$USER|" /etc/supervisor/supervisord.conf
sed -i "s|%HOME%|$HOME|" /etc/supervisor/supervisord.conf
sed -i "s|%VNC_PW%|$VNC_PW|" /etc/supervisor/supervisord.conf

# home folder
chown -R $USER:$USER $HOME

# clearup
VNC_PW=

exec /bin/tini -- /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf