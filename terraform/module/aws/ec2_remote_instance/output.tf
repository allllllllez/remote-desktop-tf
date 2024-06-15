output "public_ip" {
  value = aws_instance.ec2_remote_instance_instance.public_ip
}

output "public_dns" {
  value = aws_instance.ec2_remote_instance_instance.public_dns
}

output "instance_id" {
  value = aws_instance.ec2_remote_instance_instance.id
}
