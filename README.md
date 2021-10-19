# Terraform Module for Webserver

Part of the Week 6 SE Onboarding Terraform exercise

This is based on the Webserver module from the Week 5 exercise:
https://github.com/hashi-strawb/se-onboarding-terraform-oss/tree/main/terraform/04_packer/webserver

To build the AMI we need AWS creds

```
doormat --smoke-test || doormat -r && eval $(doormat aws --account se_demos_dev)
```
