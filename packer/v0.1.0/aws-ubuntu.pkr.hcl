packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name = "strawbtest/se-onboarding/webserver/v0.1.0"

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

    # In reality, Packer would not be responsible for promoting an AMI for use in Production
    # But for the sake of this demo, I'll do that here
    Production = true
  }

  # Remove old AMI and replace with this one
  # In Production, you would likely want to keep the old one around in case you
  # need to roll back.
  # You would also want some kind of AMI Promotion workflow.
  force_deregister = true

  force_delete_snapshot = true

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
