FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system tools and PPAs
RUN apt-get update && apt-get install -y software-properties-common gnupg2 curl ca-certificates && \
    add-apt-repository ppa:ondrej/php -y && \
    add-apt-repository ppa:mozillateam/ppa -y

# 2. Pin Firefox to the PPA (to avoid Snap)
RUN echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

# 3. Install core Desktop and Web Server (Minimized)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal tigervnc-standalone-server novnc websockify \
    sudo xterm vim net-tools dbus-x11 redis-server nginx \
    php8.3-fpm php8.3-cli firefox xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority
EXPOSE 8080

# The Start Command is handled in the Railway Dashboard for better control.
