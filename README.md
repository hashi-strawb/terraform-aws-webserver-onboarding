# Terraform Module for Webserver

Example Terraform module which provisions an NGINX webserver, running on an EC2 instance, in a new VPC.

Not particularly useful by itself, but useful for demoing Terraform in general.

To build the AMI we need AWS creds

```
doormat login -v || doormat -r && eval $(doormat aws export --account se_demos_dev)
```
