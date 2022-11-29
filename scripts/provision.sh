#!/usr/bin/env bash
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
# Provision logic for docker image creation.
set -ex

run_provision_logic() {
	mkdir -p "${HOME}/.ansible/roles"
	PATH_TO_ROLE="/ansible-vnc"
	ln -s "${PATH_TO_ROLE}" "${HOME}/.ansible/roles/cowdogmoo.vnc"
	pushd "${PROVISION_DIR}"
	ansible-galaxy install collections -r requirements.yaml
	ansible-playbook \
		--connection=local \
		--inventory 127.0.0.1, \
		--limit 127.0.0.1 workstation.yaml
	popd
}

run_provision_logic

# Wait for ansible to finish running
while /usr/bin/pgrep ansible >/dev/null; do
	echo "Ansible playbook is running"
	sleep 1
done
