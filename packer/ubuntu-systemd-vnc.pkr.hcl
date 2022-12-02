# ubuntu-systemd-vnc packer template
#
# Author: Jayson Grace <Jayson Grace <jayson.e.grace@gmail.com>
#
# Description: Create a systemd-based docker image
# that installs vnc and xfce on Ubuntu.
#
# Expected build time: ~10 minutes

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
  default = "geerlingguy/docker-ubuntu2204-ansible"
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
  type    = string
  description = "Setup vnc service with systemd."
  default = true
}

variable "workdir" {
  type    = string
  description = "Working directory for a new container."
  default = "/home/ubuntu"
}

source "docker" "systemd-vnc" {
  commit      = true
  image   = "${var.base_image}:${var.base_image_version}"
  privileged = true
  volumes = {
    "/sys/fs/cgroup" = "/sys/fs/cgroup:rw"
  }
  changes = [
    "WORKDIR ${var.workdir}",
  ]
  run_command = ["-d", "-i", "-t", "--cgroupns=host", "{{.Image}}"]
}

build {
  sources = ["source.docker.systemd-vnc"]

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
