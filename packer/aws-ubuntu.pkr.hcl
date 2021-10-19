packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name = "strawbtest/se-onboarding/webserver/v0.2.0"

  instance_type = "t2.micro"

  # region to build in
  region = "eu-west-2"

  # region to deploy to
  ami_regions = [
    "eu-west-1",
    "eu-west-2",
  ]

  tags = {
    Name    = "StrawbTest"
    Owner   = "lucy.davinhart@hashicorp.com"
    Purpose = "SE Onboarding Week 6 - TFC"
    TTL     = "24h"
    Packer  = true

    # By default, newly uploaded AMIs are not marked as safe for production
    Production = false
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "webserver"

  sources = [
    "source.amazon-ebs.ubuntu",
  ]

  provisioner "file" {
    source      = "index.html"
    destination = "/home/ubuntu/index.html"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -yq update",
      "sudo apt-get -yq install nginx",
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html",
    ]
  }
}
