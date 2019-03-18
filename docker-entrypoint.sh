#!/bin/sh
set -e
cd /mailhog
mailhog &
ghostunnel server \
    --listen 0.0.0.0:1026 \
    --target localhost:1025 \
    --cert /certs/server.crt \
    --key /certs/server.key \
    --disable-authentication
