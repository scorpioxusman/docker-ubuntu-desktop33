#!/bin/bash

# 1. Start Tailscale background engine
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# 2. Wait 15 seconds for the engine to initialize
sleep 15

# 3. Authenticate using the NEW key (Quotes prevent the dash error)
/usr/bin/tailscale up --auth-key='tskey-auth-k6QJqjGM7z11CNTRL-rHVyrXkHiAZU4SeDEcVoAZHRKMAj6biFS' --accept-dns=false --hostname=railway-desktop

# 4. Start Redis in background
/usr/bin/redis-server --daemonize yes

# 5. Clear old RDP lock files
rm -f /var/run/xrdp/*.pid

# 6. Start RDP Session Manager
/usr/sbin/xrdp-sesman

# 7. Start XRDP (nodaemon keeps the container running)
/usr/sbin/xrdp --nodaemon
