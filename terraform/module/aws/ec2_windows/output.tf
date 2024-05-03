output "public_ip" {
  value = aws_instance.ec2_windows_instance.public_ip
}

output "public_dns" {
  value = aws_instance.ec2_windows_instance.public_dns
}
