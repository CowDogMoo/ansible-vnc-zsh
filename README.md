# Ansible Role: vnc + oh-my-zsh

[![Pre-Commit](https://github.com/cowdogmoo/ansible-vnc-zsh/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc-zsh/actions/workflows/pre-commit.yaml)
[![Molecule Test](https://github.com/cowdogmoo/ansible-vnc-zsh/actions/workflows/molecule.yaml/badge.svg)](https://github.com/cowdogmoo/ansible-vnc-zsh/actions/workflows/molecule.yaml)
[![Ansible Galaxy](https://img.shields.io/badge/Galaxy-cowdogmoo.vnc_zsh-660198.svg?style=flat)](https://galaxy.ansible.com/ui/standalone/roles/CowDogMoo/vnc_zsh)
[![License](https://img.shields.io/github/license/CowDogMoo/ansible-vnc-zsh?label=License&style=flat&color=blue&logo=github)](https://github.com/CowDogMoo/ansible-vnc-zsh/blob/main/LICENSE)

This role installs [vnc](https://tigervnc.org/) and
[oh-my-zsh](https://ohmyz.sh/) on Debian-based systems.

## Requirements

- Python packages

  Install with:

  ```bash
  python3 -m pip install --upgrade \
    ansible-core \
    molecule \
    molecule-docker \
    "molecule-plugins[docker]"
  ```

---

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yaml`):

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
  - colordiff
  - curl
...
```

---

## Local Development

Make sure to run the following to develop locally:

```bash
ansible-galaxy install -r requirements.yml
PATH_TO_ROLE="${PWD}"
ln -s "${PATH_TO_ROLE}" "${HOME}/.ansible/roles/cowdogmoo.vnc_zsh"
```

---

## Get vnc password

A random 8-character password is generated when the role
is run initially. To retrieve it, run this command on the
provisioned system:

```bash
/usr/local/bin/vncpwd /home/ubuntu/.vnc/passwd
```

---

## Testing

To test actions locally, you can install [act](https://github.com/nektos/act)
and use the following command:

```bash
ACTION="molecule"
if [[ $(uname) == "Darwin" ]]; then
  act -j $ACTION --container-architecture linux/amd64
fi
```

To test changes made to this role locally, run the following commands:

```bash
molecule create
molecule converge
molecule idempotence
# If everything passed, tear down the docker container spawned by molecule:
molecule destroy
```
