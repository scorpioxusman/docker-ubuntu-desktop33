#!/bin/bash

# 1. Start Tailscale background engine
# Note: --tun=userspace-networking is required for Docker containers
sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# 2. Re-connect Tailscale (using your Auth Key if available)
# If you don't use a key, check your Railway logs for the login link
sudo tailscale up --authkey=${TAILSCALE_AUTHKEY} --accept-dns=false

# 3. Start Redis in the background
sudo redis-server --daemonize yes

# 4. Clear any old RDP "Lock" files from previous crashes
sudo rm -rf /var/run/xrdp/*.pid

# 5. Start XRDP services manually
sudo /usr/sbin/xrdp-sesman
sudo /usr/sbin/xrdp --nodaemon
