#!/bin/bash
set -ex

# Create random 8 character VNC password
VNC_PWD="$(
	head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8
	echo ''
)"
export VNC_PW

# Set the random 8 character VNC password
/usr/bin/vncpasswd -f <<<"${VNC_PWD}" >"${HOME}/.vnc/passwd"

# Start vncserver
/usr/bin/vncserver :1 -geometry 1920x1080 --localhost no -PasswordFile "${HOME}/.vnc/passwd"

exec "$@"
