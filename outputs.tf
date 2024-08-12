
output "ec2_connect_url" {
  value = "https://${data.aws_region.current.name}.console.aws.amazon.com/ec2/home?region=eu-west-2#ConnectToInstance:instanceId=${aws_instance.web.id}"
}

output "web_server_ip" {
  value = "http://${aws_instance.web.public_ip}"
}

output "web_server_url" {
  value = local.webserver_url
}

output "terracurl_identity_response" {
  value = data.terracurl_request.test_identity.response
}
