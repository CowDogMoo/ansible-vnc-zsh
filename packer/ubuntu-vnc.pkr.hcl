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
  default = "geerlingguy/docker-ubuntu2204-ansible"
}

variable "docker_image_version" {
  type    = string
  default = "${env("IMAGE_VERSION")}"
}

variable "provision_dir" {
  type    = string
  default = "/ansible-vnc"
}

source "docker" "vnc" {
  commit      = true
  image   = "${var.docker_base_image}:${var.docker_image_version}"
  privileged = true
  volumes = {
    "/sys/fs/cgroup" = "/sys/fs/cgroup:rw"
  }
  run_command = ["-d", "-i", "-t", "--cgroupns=host", "{{.Image}}"]
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
      repository = "cowdogmoo/ansible-vnc"
    }
  }
}
