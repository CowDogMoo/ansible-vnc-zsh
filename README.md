# Ansible Role: vnc + oh-my-zsh

[![Pre-Commit](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/pre-commit.yaml)
[![Molecule Test](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/molecule.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc/actions/workflows/molecule.yaml)

This role installs [vnc](https://github.com/cowdogmoo/vnc) and
[oh-my-zsh](https://ohmyz.sh/) on Ubuntu hosts.

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

Path to `python3` interpreter.

```yaml
ansible_python_interpreter: /usr/bin/python3
```

Path to clone [vncpwd](https://github.com/jeroennijhof/vncpwd).

```yaml
vncpwd_clone_path: /tmp/vncpwd
```

URL for the oh-my-zsh install script.

```yaml
omz_install_script_url: "https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh"
```

URL to clone [vncpwd](https://github.com/jeroennijhof/vncpwd) from.

```yaml
vncpwd_repo_url: https://github.com/jeroennijhof/vncpwd.git
```

Location on disk to install vncpwd.

```yaml
vncpwd_path: /usr/local/bin/vncpwd
```

Client options for `vnc`.

```yaml
vnc_client_options: "-geometry 1920x1080 --localhost no"
```

Specify whether to setup a systemd service to manage
the vnc installation. Worth considering if you are
using this role outside of a container.

```yaml
setup_systemd: false
```

Oh-my-zsh theme to install.

```yaml
zsh_theme: "af-magic"
```

**Debian-specific vars:**

Users to configure `vnc` for.

```yaml
vnc_users:
  - username: "ubuntu"
    usergroup: "ubuntu"
    sudo: true
    # port 5901
    vnc_num: 1
```

Required packages for the installation.

```yaml:
install_packages:
  - bash
  - ca-certificates
  - curl
  - dbus-x11
...
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

## Build docker image with Packer

```bash
# Without systemd
IMAGE_TAG=cowdogmoo/ansible-vnc \
BASE_IMAGE_VERSION=latest \
NEW_IMAGE_VERSION=latest \
packer build packer/ubuntu-vnc.pkr.hcl

# With systemd
IMAGE_TAG=cowdogmoo/ansible-systemd-vnc \
BASE_IMAGE_VERSION=latest \
NEW_IMAGE_VERSION=latest \
packer build packer/ubuntu-systemd-vnc.pkr.hcl
```

## Run container

```bash
# Without systemd
docker run -dit --rm -p 5901:5901 cowdogmoo/ansible-vnc \
&& CONTAINER=$(docker ps | awk -F '  ' '{print $7}' | xargs) \
&& echo $CONTAINER && docker exec -it $CONTAINER zsh

# With systemd
docker run -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --rm -it -p 5901:5901 --cgroupns=host cowdogmoo/ansible-systemd-vnc \
&& CONTAINER=$(docker ps | awk -F '  ' '{print $7}' | xargs) \
&& echo $CONTAINER && docker exec -it $CONTAINER zsh
```

## Get vnc password

```bash
docker exec -it $CONTAINER zsh -c '/usr/local/bin/vncpwd /home/ubuntu/.vnc/passwd'
```
