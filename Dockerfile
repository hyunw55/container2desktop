FROM centos:7

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901

EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=password \
    VNC_VIEW_ONLY=false

WORKDIR $HOME

### Install some common tools
RUN echo "Install some common tools for further installation"  && \
yum -y install epel-release  && \
yum -y update  && \
yum -y install vim sudo wget which net-tools bzip2 \
    numpy #used for websockify/novnc  && \
yum -y install mailcap  && \
yum clean all && \
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
# tigervnc
# RUN echo "Install TigerVNC server"  && \
# wget https://dl.bintray.com/tigervnc/stable/tigervnc-el7.repo -O /etc/yum.repos.d/tigervnc.repo  && \
# yum -y install tigervnc-server  && \
# yum clean all



# install novnc
RUN echo "Install noVNC - HTML5 based VNC viewer" && \
mkdir -p $NO_VNC_HOME/utils/websockify && \
wget -qO- https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME && \
wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify && \
chmod +x -v $NO_VNC_HOME/utils/*.sh && \
ln -s $NO_VNC_HOME/vnc.html $NO_VNC_HOME/index.html

# install xfce-ui
RUN echo "Install Xfce4 UI components and disable xfce-polkit" && \
yum --enablerepo=epel -y -x gnome-keyring --skip-broken groups install "Xfce"  && \
yum -y groups install "Fonts" && \
yum erase -y *power* *screensaver* && \
yum clean all && \
rm /etc/xdg/autostart/xfce-polkit* && \
/bin/dbus-uuidgen > /etc/machine-id

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

# USER 1000
COPY startup.sh /startup.sh
RUN yum install -y supervisor
RUN yum install -y xorg-x11-server-Xvfb
RUN yum install -y x11vnc
RUN sudo yum groupinstall -y "Xfce"

COPY code-server_3.8.0_amd64.deb /tmp/code-server.deb
RUN yum -y install epel-release &&  yum install -y dpkg-devel dpkg-dev

RUN cd /tmp && dpkg -i code-server.deb

COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN chmod a+x /startup.sh
ENTRYPOINT ["/startup.sh"]
# CMD ["--wait"]

 
