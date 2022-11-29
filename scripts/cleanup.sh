#!/usr/bin/env bash
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
# Clean up after provisioning has finished.
set -ex

/usr/bin/yes | python3 -m pip uninstall ansible
apt-get remove -y python3-pip

rm -rf /ansible-vnc
