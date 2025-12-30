FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install prerequisites for adding repositories & GPG keys
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg2 \
    curl \
    ca-certificates

# 2. Add PHP 8.3 and Firefox (Non-Snap) Repositories
RUN add-apt-repository ppa:ondrej/php -y && \
    add-apt-repository ppa:mozillateam/ppa -y

# 3. Configure Firefox Priority (to prevent Snap transition)
RUN echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

# 4. Install Desktop, PHP 8.3, Nginx, and Firefox
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    vim \
    net-tools \
    dbus-x11 \
    redis-server \
    nginx \
    php8.3-fpm \
    php8.3-cli \
    php8.3-common \
    firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 5. Final setup
RUN touch /root/.Xauthority
EXPOSE 8080

# 6. Startup Command
CMD bash -c "mkdir -p /run/php && chmod 755 /run/php && \
    redis-server --daemonize yes && \
    /usr/sbin/php-fpm8.3 --daemonize && \
    nginx && \
    vncserver -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE && \
    websockify --web=/usr/share/novnc/ 8080 localhost:5901"
