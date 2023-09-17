# output "public_subnets" {
#   value = module.ec2_vpc.public_subnets
# }

# output "private_subnets" {
#   value = module.ec2_vpc.private_subnets
# }

output "public_dns" {
  value = "Public DNS: ${aws_instance.ec2_insecre.public_dns}"
}

output "URL" {
  value = "http://${aws_instance.ec2_insecre.public_ip}:8080"
}
