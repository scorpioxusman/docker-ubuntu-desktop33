FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Core Dependencies & Tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    curl \
    wget \
    git \
    vim \
    net-tools \
    dbus-x11 \
    x11-xserver-utils \
    software-properties-common \
    gnupg2 \
    redis-server \
    xrdp \
    xubuntu-icon-theme \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Fix Firefox PPA (GPG Fix)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox

# 3. Setup User & Permissions
RUN touch /root/.Xauthority && \
    echo "ubuntu:password123" | chpasswd && \
    adduser ubuntu sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/etc/sudoers

# 4. Open Ports for RDP and VNC/NoVNC
EXPOSE 3389 5901 6080

# 5. Start Command (Everything in one string for Railway)
# This includes Ngrok setup as you requested
CMD bash -c "echo 'Setting up environment...' && \
    redis-server --daemonize yes && \
    rm -f /var/run/xrdp/*.pid && \
    /usr/sbin/xrdp-sesman && \
    /usr/sbin/xrdp && \
    echo 'VPS is ready. Ensure your Railway Start Command contains your Ngrok token.' && \
    tail -f /dev/null"
