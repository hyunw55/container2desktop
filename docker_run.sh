VNC_COL_DEPTH=24
VNC_RESOLUTION=1920x1080
VNC_PW=1234

docker run --privileged -e USER_NAME=$USER -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) \
 -e VNC_COL_DEPTH=$VNC_COL_DEPTH -e VNC_RESOLUTION=$VNC_RESOLUTION \
 -e VNC_PW=$VNC_PW -v /home/$USER:/home/$USER -p 6901:6901 -p 5901:5901 -p 6081:6081 -p 8080:8080 -it container2pc /bin/bash
