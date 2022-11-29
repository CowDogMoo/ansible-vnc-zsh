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

source "docker" "vnc" {
  commit      = true
  image   = "${var.base_image}:${var.base_image_version}"
  changes = [
    "ENTRYPOINT [\"${var.provision_dir}/scripts/provision.sh\"]",
    "CMD [\"zsh\"]"
  ]
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

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.image_tag}"
      tag = ["${var.new_image_version}"]
    }
  }
}
