# Ansible Role: vnc

[![Pre-Commit](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/pre-commit.yaml)
[![Molecule Test](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/molecule.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/molecule.yaml)

This role installs [vnc](https://github.com/cowdogmoo/vnc) on Linux hosts.

## Requirements

- Python packages

  Install with:

  ```bash
  python3.9 -m pip install --upgrade molecule-docker
  ```

- `community.general.make`

  Install with:

  ```bash
  ansible-galaxy install collections -r requirements.yaml
  ```

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

Path to python3 interpreter.

```yaml
ansible_python_interpreter: /usr/bin/python3
```

URL for the oh-my-zsh install script.

```yaml
omz_install_script_url: "https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh"
```

Client options for `vnc`.

```yaml
vnc_client_options: "-geometry 1920x1080 --localhost no"
```

Users to configure `vnc` for.

```yaml
vnc_users:
  - username: "ubuntu"
    usergroup: "ubuntu"
    # port 5901
    vnc_num: 1
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: cowdogmoo.vnc
```

## Local Development

Make sure to run the following to develop locally:

```bash
ansible-galaxy collection install -r requirements.yml
PATH_TO_ROLE="${PWD}"
ln -s "${PATH_TO_ROLE}" "${HOME}/.ansible/roles/cowdogmoo.vnc"
```

## Testing

To test changes made to this role, run the following commands:

```bash
molecule create
molecule converge
# If everything passed, tear down the docker container spawned by molecule:
molecule destroy
```

## Run Packer

```bash
IMAGE_VERSION=latest packer build packer/ubuntu-vnc.pkr.hcl
```
