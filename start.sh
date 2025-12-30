#!/bin/bash

# Start Tailscale engine
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# Wait for engine
sleep 15

# Authenticate using the FULL key inside single quotes
/usr/bin/tailscale up --auth-key='tskey-auth-kPuq2cnSWR11CNTRL-UNK3bNLctdL8EVNDp8CxdLfeYkiqXvwP' --accept-dns=false --hostname=railway-desktop

# Start services
/usr/bin/redis-server --daemonize yes
rm -f /var/run/xrdp/*.pid
/usr/sbin/xrdp-sesman
/usr/sbin/xrdp --nodaemon
