variable "ami_name" {
  type        = string
  default     = "strawbtest/demo/webserver/v0.1.0"
  description = "Which version of the AMI should we use?"
}

variable "image_type" {
  type        = string
  default     = "cat"
  description = "Type of image to show"
}
variable "image_width" {
  type        = string
  default     = "560"
  description = "Width of image"
}
variable "image_height" {
  type        = string
  default     = "400"
  description = "Height of image"
}

locals {
  image_url = "https://placebear.com/560/400"
}
