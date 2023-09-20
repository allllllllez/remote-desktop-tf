# EC2 (Windows Server インスタンス)
resource "aws_instance" "ec2_insecre" {
  # Windows_Server-2019-English-Full-ECS_Optimized-2021.02.10 →  Error launching source instance: AuthFailure: Not authorized for images: [ami-0f0cd3f9f601e909e]
  # ami = "ami-0f0cd3f9f601e909e"
  # Microsoft Windows Server 2022 Base with Containers / ap-northeast-1
  # ami = "ami-0cead27965999bdc5"
  # Microsoft Windows Server 2022 at us-west-2
  ami = "ami-07e70003c665fb5f3"

  instance_type = var.instance_type

  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  key_name = var.key_name

  # インスタンス起動時に実行するscript
  user_data = base64encode(local.user_data_git_win)

  tags = var.tags
}
