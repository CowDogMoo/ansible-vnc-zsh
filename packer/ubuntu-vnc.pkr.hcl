# ubuntu-vnc packer template
#
# Used to create a docker image
# that installs vnc and xfce on ubuntu.
#
# It is slower to build than the systemd
# template because ansible needs to be
# installed as part of the provisioning process.
#
# Expected build time: ~15 minutes

# Define the plugin used by Packer
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "docker_base_image" {
  type    = string
  default = "ubuntu:22.04"
}

variable "docker_image_tag" {
  type    = string
  default = "${env("IMAGE_TAG")}"
}

variable "provision_dir" {
  type    = string
  default = "/ansible-vnc"
}

source "docker" "vnc" {
  commit      = true
  image   = "${var.docker_base_image}"
  run_command = ["-d", "-i", "-t", "{{.Image}}"]
}

build {
  sources = ["source.docker.vnc"]

  provisioner "file" {
    destination = "${var.provision_dir}"
    source      = "${path.cwd}"
  }

  provisioner "shell" {
    environment_vars = ["PROVISION_DIR=${var.provision_dir}"]
    script           = "scripts/provision.sh"
  }

  provisioner "shell" {
    script           = "scripts/cleanup.sh"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.docker_image_tag}"
    }
  }
}
