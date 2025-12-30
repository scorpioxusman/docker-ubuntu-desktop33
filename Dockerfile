# Removed the platform flag to avoid the warning and resolve the timeout
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Consolidated installs to reduce build steps (and network calls)
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common gnupg2 redis-server xrdp xubuntu-icon-theme \
    nginx php8.3-fpm php8.3-cli php8.3-common

# Fix Firefox PPA
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update -y && apt install -y firefox

RUN touch /root/.Xauthority
EXPOSE 8080

# Combined Startup Command including directory fixes for PHP
CMD bash -c "mkdir -p /run/php && chmod 755 /run/php && \
    redis-server --daemonize yes && \
    /usr/sbin/php-fpm8.3 --daemonize && \
    nginx && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE && \
    websockify --web=/usr/share/novnc/ 8080 localhost:5901"
