packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name = "strawbtest/demo/webserver/v0.2.0"

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
    Purpose = "Dummy Webserver for TFC Demo"
    TTL     = "24h"
    Packer  = true
    Source  = "https://github.com/hashi-strawb/packer-demo-webserver/tree/main/packer/v0.2.0"

    # By default, newly uploaded AMIs are not marked as safe for production
    Production = false
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

  hcp_packer_registry {
    bucket_name = "aws-webserver"

    description = <<EOT
Dummy webserver for demonstration purposes
    EOT

    bucket_labels = {
      "owner" = "platform-team"
    }

    build_labels = {
      "os"             = "Ubuntu"
      "ubuntu-version" = "Focal 20.04"
      "version"        = "v0.2.0"
    }
  }

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
