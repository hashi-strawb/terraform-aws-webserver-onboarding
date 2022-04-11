variable "packer_bucket_name" {
  type        = string
  default     = "aws-webserver"
  description = "Which HCP Packer bucket should we pull our AMI from?"
}

variable "packer_channel" {
  type        = string
  default     = "production"
  description = "Which HCP Packer channel should we use for our AMI?"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "How big of an instance should we create?"
}
