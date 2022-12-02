# ubuntu-vnc packer template
#
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
#
# Description: Create a docker image
# that installs vnc and xfce on Ubuntu.
#
# It is slower to build than its systemd counterpart
# because the systemd image already has
# ansible installed.
#
# Expected build time: ~12 minutes

# Define the plugin(s) used by Packer.
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "base_image" {
  type    = string
  description = "Base image."
  default = "ubuntu"
}

variable "base_image_version" {
  type    = string
  description = "Version of the base image."
  default = "${env("BASE_IMAGE_VERSION")}"
}

variable "container_user" {
  type    = string
  description = "Default user for a new container."
  default = "ubuntu"
}

variable "image_tag" {
  type    = string
  description = "Tag for the created image."
  default = "${env("IMAGE_TAG")}"
}

variable "new_image_version" {
  type = string
  description = "Version for the created image."
  default = "${env("NEW_IMAGE_VERSION")}"
}

variable "provision_dir" {
  type    = string
  description = "Directory to use for provisioning."
  default = "/ansible-vnc"
}

variable "setup_systemd" {
  type    = bool
  description = "Setup vnc service with systemd."
  default = false
}

variable "workdir" {
  type    = string
  description = "Working directory for a new container."
  default = "/home/ubuntu"
}

source "docker" "vnc" {
  commit      = true
  image   = "${var.base_image}:${var.base_image_version}"
  changes = [
    "USER ${var.container_user}",
    "WORKDIR ${var.workdir}",
    "ENTRYPOINT /run/docker-entrypoint.sh ; zsh",
  ]
  run_command = ["-d", "-i", "-t", "{{.Image}}"]
}

build {
  sources = ["source.docker.vnc"]

  provisioner "file" {
    destination = "${var.provision_dir}/"
    source      = "${path.cwd}"
  }

  provisioner "shell" {
    environment_vars = [
      "PROVISION_DIR=${var.provision_dir}",
      "SETUP_SYSTEMD=${var.setup_systemd}",
      ]
    script           = "scripts/provision.sh"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.image_tag}"
      tag = ["${var.new_image_version}"]
    }
  }
}
