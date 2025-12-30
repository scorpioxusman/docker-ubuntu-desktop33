FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Consolidated Updates and Installs
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm init systemd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    redis-server xrdp xubuntu-icon-theme && \
    curl -fsSL https://tailscale.com/install.sh | sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Firefox PPA Setup
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox

# 3. Setup User Environment
RUN touch /root/.Xauthority && \
    echo "ubuntu:password123" | chpasswd

# 4. Exposure
EXPOSE 5901 6080 3389

# 5. The Correct Startup Command (At the BOTTOM)
# This starts Tailscale, VNC, and XRDP together
CMD bash -c "/usr/sbin/tailscaled --tun=userspace-networking & \
    sleep 5 && \
    /usr/bin/tailscale up --auth-key='tskey-auth-kd8uiJqS5511CNTRL-QSznzFWE6t9nVQ6GjEr9t9oGDGkgjzo4' --accept-dns=false --hostname=railway-desktop && \
    vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
    redis-server --daemonize yes && \
    rm -f /var/run/xrdp/*.pid && \
    /usr/sbin/xrdp-sesman && \
    /usr/sbin/xrdp --nodaemon"
