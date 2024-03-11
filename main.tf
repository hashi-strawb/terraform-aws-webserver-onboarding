terraform {
  # We're using Terraform Checks
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.82"
    }
  }
}

# As this is now a TF module, we can't assume eu-west-2
# So get AZs and region dynamically
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_region" "current" {}

# Create a VPC
# While we could define each of the required resources manually...
# no need to re-invent the wheel when a really good module exists already

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest 
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs            = data.aws_availability_zones.available.names[*]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Allow us to easily connect to the EC2 instance with AWS EC2 Connect

data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [data.aws_region.current.name]
  services = ["ec2_instance_connect"]
}

resource "aws_security_group" "ec2_instance_connect" {
  name        = "ec2_instance_connect"
  description = "Allow EC2 Instance Connect to access this host"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    cidr_blocks      = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
    ipv6_cidr_blocks = data.aws_ip_ranges.ec2_instance_connect.ipv6_cidr_blocks
  }

  tags = {
    CreateDate = data.aws_ip_ranges.ec2_instance_connect.create_date
    SyncToken  = data.aws_ip_ranges.ec2_instance_connect.sync_token
  }
}

# Allow inbound HTTP access on standard port
# In Production, you'd want to configure SSL etc.
# potentially run behind a load balancer of some kind.
# you know, usual production stuff.
#
# But for this demo, this works fine.
resource "aws_security_group" "inbound_http" {
  name        = "inbound_http"
  description = "Allow inbound HTTP access"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# Find a suitable AMI to use for this purpose
data "hcp_packer_artifact" "webserver" {
  bucket_name  = var.packer_bucket_name
  channel_name = var.packer_channel
  platform     = "aws"

  region = data.aws_region.current.name

  /*
  lifecycle {
    postcondition {
      condition     = timecmp(plantimestamp(), timeadd(self.created_at, "40m")) < 0
      error_message = "The image referenced in the Packer bucket is more than 40 minutes old."
    }
  }
  */
}

# Now create the EC2 instance
resource "aws_instance" "web" {
  ami = data.hcp_packer_artifact.webserver.external_identifier
  tags = {
    "packer_bucket_name" = var.packer_bucket_name
    "packer_channel"     = var.packer_channel
  }

  associate_public_ip_address = true


  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.ec2_instance_connect.id,
    aws_security_group.inbound_http.id,
  ]

  subnet_id = module.vpc.public_subnets[0]

  lifecycle {
    create_before_destroy = true

    /*
    postcondition {
      condition     = self.ami == data.hcp_packer_artifact.webserver.external_identifier
      error_message = "Newer AMI available: ${data.hcp_packer_artifact.webserver.external_identifier}"
    }
    */
  }
}

check "latest_ami" {
  # Workaround for check{} blocks currently evaluating against the future
  # state of the resource: use current state instead, from a data source
  data "aws_instance" "web" {
    # Can't use instance_id either, because in the case of a newer AMI, that ID is going to change too
    # instance_id = aws_instance.web.id

    instance_tags = {
      "packer_bucket_name" = var.packer_bucket_name
      "packer_channel"     = var.packer_channel
    }
  }

  assert {
    condition     = data.aws_instance.web.ami == data.hcp_packer_artifact.webserver.external_identifier
    error_message = <<-EOF
    Newer AMI available: ${data.hcp_packer_artifact.webserver.bucket_name}:${data.hcp_packer_artifact.webserver.channel_name} v${data.hcp_packer_artifact.webserver.version_fingerprint} = ${data.hcp_packer_artifact.webserver.external_identifier}

    https://portal.cloud.hashicorp.com/services/packer/buckets/${var.packer_bucket_name}/versions/?project_id=${data.hcp_packer_artifact.webserver.project_id}
    EOF
  }
}

check "ami_age" {
  # Deliberately short TTL, to check if Health Checks pick this up
  assert {
    condition     = timecmp(plantimestamp(), timeadd(data.hcp_packer_artifact.webserver.created_at, "720h")) < 0
    error_message = "The image referenced in the Packer bucket is more than 30 days old."
  }
}
