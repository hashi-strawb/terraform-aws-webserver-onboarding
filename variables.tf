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
  urls = {
    "cat"     = "https://placekitten.com/${var.image_width}/${var.image_height}"
    "dog"     = "https://placedog.net/${var.image_width}/${var.image_height}"
    "bear"    = "https://placebear.com/${var.image_width}/${var.image_height}"
    "niccage" = "https://www.placecage.com/${var.image_width}/${var.image_height}"
  }

  image_url = local.urls[var.image_type]
}
