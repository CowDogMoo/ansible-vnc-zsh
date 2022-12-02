#!/usr/bin/env bash
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
# Provision logic for docker image creation.
set -ex

export PATH_TO_ROLE="/ansible-vnc"

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
	ln -s "${PATH_TO_ROLE}" "${HOME}/.ansible/roles/cowdogmoo.vnc"
	pushd "${PROVISION_DIR}"
	ansible-playbook \
		--connection=local \
		--inventory 127.0.0.1, \
		-e "setup_systemd=${SETUP_SYSTEMD}" \
		--limit 127.0.0.1 workstation.yaml
	popd

	# Wait for ansible to finish running
	while /usr/bin/pgrep ansible >/dev/null; do
		echo "Ansible playbook is running"
		sleep 1
	done
}

cleanup() {
	# Uninstall unneeded provisioning dependencies
	/usr/bin/yes | python3 -m pip uninstall ansible

	# Remove provisioning directory.
	rm -rf "${PATH_TO_ROLE}"
	rm -rf /packer-files
}

install_dependencies
run_provision_logic
cleanup
