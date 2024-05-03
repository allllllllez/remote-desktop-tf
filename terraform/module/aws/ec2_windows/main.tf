# 
# EC2（キーペア付き） + Security Group in VPC を立てる
# 

# 
# VPC
#

# Security group
resource "aws_security_group" "ec2_windows_security_group" {
  name        = "ec2_windows_security_group"
  description = "Security group for Windows Server"
  vpc_id      = module.ec2_windows_vpc.vpc_id

  tags = var.tags
}

# 指定IPからのRDPのみ許可する
resource "aws_vpc_security_group_ingress_rule" "ec2_windows_security_group_ingress_rule" {
  security_group_id = aws_security_group.ec2_windows_security_group.id
  cidr_ipv4         = [var.my_ip_address]
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "RDP"
}

# VPC
module "ec2_windows_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name                 = "ec2_windows_vpc"
  cidr                 = var.vpc_cidr
  enable_dns_hostnames = true
  create_vpc           = true
  azs                  = var.azs
  public_subnets       = [cidrsubnet(var.vpc_cidr, 8, 0)]
  # public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  # private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  public_subnet_tags = var.tags

  tags = var.tags
}

# 
# EC2 keypair
# 
module "ec2_keypair" {
  source   = "../ec2_keypair"
  key_name = var.key_name
}


# EC2 (Windows Server インスタンス)
resource "aws_instance" "ec2_windows_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2_windows_security_group.id
  ]

  subnet_id                   = module.ec2_windows_vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = module.ec2_keypair.key_pair_name

  # インスタンス起動時に実行するscript
  user_data = base64encode(local.user_data_git_win)

  tags = var.tags
}
