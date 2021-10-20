
output "ec2_connect_url" {
  value = "https://${data.aws_region.current.name}.console.aws.amazon.com/ec2/v2/connect/ubuntu/${aws_instance.web.id}"
}

output "web_server_url" {
  value = "http://${aws_instance.web.public_ip}"
}
