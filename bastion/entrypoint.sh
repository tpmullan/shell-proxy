#!/bin/sh
# Generates missing SSH host keys (so they persist in the /config volume),
# starts shell-proxy-ctl's companion daemon in a restart loop, then execs
# sshd as the foreground process.
set -e

mkdir -p /config/ssh_host_keys /config/.ssh
for type in rsa ecdsa ed25519; do
  key="/config/ssh_host_keys/ssh_host_${type}_key"
  [ -f "$key" ] || ssh-keygen -q -t "$type" -N "" -f "$key"
done
touch /config/.ssh/authorized_keys
chown -R "$SHELL_PROXY_USER:$SHELL_PROXY_USER" /config/.ssh
chmod 700 /config/.ssh
chmod 600 /config/.ssh/authorized_keys

(
  while true; do
    su-exec "$SHELL_PROXY_USER" shell-proxy-ctl serve
    status=$?
    echo "shell-proxy-ctl serve exited (status $status), restarting in 2s" >&2
    sleep 2
  done
) &

exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
