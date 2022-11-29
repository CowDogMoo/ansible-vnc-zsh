#!/usr/bin/env bash
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
# Provision logic for docker image creation.
set -ex

install_dependencies() {
	# Get latest packages and install aptitude
	apt update -y 2>/dev/null | grep packages | cut -d '.' -f 1
	apt install -y aptitude 2>/dev/null | grep packages | cut -d '.' -f 1

	# Install ansible and associated pre-requisites
	aptitude install -y bash python3 python3-pip
	python3 -m pip install --upgrade pip wheel setuptools ansible
}

run_provision_logic() {
	mkdir -p "${HOME}/.ansible/roles"
	PATH_TO_ROLE="/ansible-vnc"
	ln -s "${PATH_TO_ROLE}" "${HOME}/.ansible/roles/cowdogmoo.vnc"
	pushd "${PROVISION_DIR}"
	ansible-galaxy collection install -r requirements.yaml
	ansible-playbook \
		--connection=local \
		--inventory 127.0.0.1, \
		--limit 127.0.0.1 workstation.yaml
	popd
}

install_dependencies
run_provision_logic

# Wait for ansible to finish running
while /usr/bin/pgrep ansible >/dev/null; do
	echo "Ansible playbook is running"
	sleep 1
done
