#!/bin/bash

# 1. Start Tailscale engine in the background
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# 2. Give the engine time to wake up
sleep 15

# 3. Authenticate with your new REUSABLE key
/usr/bin/tailscale up --auth-key=tskey-auth-kPuq2cnSWR11CNTRL-UNK3bNLctdL8EVNDp8CxdLfeYkiqXvwP --accept-dns=false --hostname=railway-desktop

# 4. Start Redis
/usr/bin/redis-server --daemonize yes

# 5. Clean up RDP and start it
rm -f /var/run/xrdp/*.pid
/usr/sbin/xrdp-sesman
/usr/sbin/xrdp --nodaemon
