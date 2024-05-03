output "public_ip" {
  value = aws_instance.ec2_insecre.public_ip
}

output "public_dns" {
  value = aws_instance.ec2_insecre.public_dns
}
