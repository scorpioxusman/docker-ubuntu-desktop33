FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install all desktop and core components
# Removed 'snapd' as it cannot run in Railway/Docker
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common gnupg2 redis-server xrdp

# 2. Setup Firefox via PPA (Non-Snap version)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update -y && apt install -y firefox

RUN apt install -y xubuntu-icon-theme
RUN touch /root/.Xauthority

# 3. Configure the 'ubuntu' user for login
RUN echo "ubuntu:password123" | chpasswd && \
    adduser ubuntu sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

EXPOSE 5901
EXPOSE 6080
EXPOSE 3389

# 4. Manual Service Startup (This replaces systemd)
CMD bash -c "\
    # Start Redis in background \
    redis-server --daemonize yes && \
    # Start VNC for the web browser view \
    vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
    # Setup Web-based VNC (NoVNC) \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    # Start XRDP for Remote Desktop \
    rm -f /var/run/xrdp/*.pid && \
    /usr/sbin/xrdp-sesman && \
    /usr/sbin/xrdp --nodaemon"
