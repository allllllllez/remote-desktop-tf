# 
# EC2（キーペア付き） + Security Group in VPC を立てる
# 

# 
# VPC
#

# Security group
resource "aws_security_group" "ec2_remote_instance_security_group" {
  name        = "ec2_remote_instance_security_group"
  description = "Security group for Windows Server"
  vpc_id      = module.ec2_remote_instance_vpc.vpc_id

  tags = var.tags
}

# 指定IPからのsshのみ許可する
resource "aws_vpc_security_group_ingress_rule" "ec2_remote_instance_security_group_ingress_rule_ssh" {
  security_group_id = aws_security_group.ec2_remote_instance_security_group.id
  cidr_ipv4         = var.my_ip_address
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# 指定IPからのRDPのみ許可する
resource "aws_vpc_security_group_ingress_rule" "ec2_remote_instance_security_group_ingress_rule_rdp" {
  security_group_id = aws_security_group.ec2_remote_instance_security_group.id
  cidr_ipv4         = var.my_ip_address
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "27" # rdp cf. https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
}

# VPC
module "ec2_remote_instance_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name                 = "ec2_remote_instance_vpc"
  cidr                 = var.vpc_cidr
  enable_dns_hostnames = true
  create_vpc           = true
  azs                  = var.azs
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0), # default: 10.0.0.0/24 (10.0.0.1 - 10.0.0.255)
    cidrsubnet(var.vpc_cidr, 8, 1)  # default: 10.0.1.0/24 (10.0.1.1 - 10.0.1.255)
  ]
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 2), # default: 10.0.2.0/24 (10.2.0.1 - 10.2.0.255)
    cidrsubnet(var.vpc_cidr, 8, 3)  # default: 10.0.3.0/24 (10.3.0.1 - 10.3.0.255)
  ]

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

data "aws_ami" "ec2_remote_instance_ami" {
  most_recent        = true
  include_deprecated = true
  filter {
    name   = "name"
    values = var.ami_name_patterns
  }
}

# EC2 (Windows Server インスタンス)
resource "aws_instance" "ec2_remote_instance" {
  ami           = data.aws_ami.ec2_remote_instance_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2_remote_instance_security_group.id
  ]

  subnet_id                   = module.ec2_remote_instance_vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = module.ec2_keypair.key_pair_name

  # インスタンス起動時に実行するscript
  user_data = file(var.user_data_script)

  tags = var.tags
}

# ec2 instance connect endpoint
resource "aws_ec2_instance_connect_endpoint" "ec2_remote_instance_connect_endpoint" {
  subnet_id          = module.ec2_remote_instance_vpc.private_subnets[0] # 必須
  security_group_ids = [aws_security_group.ec2_remote_instance_connect_endpoint.id]
  preserve_client_ip = true

  tags = var.tags
}

# Security group
resource "aws_security_group" "ec2_remote_instance_connect_endpoint" {
  name   = "ec2_remote_instance_connect_endpoint_security_group"
  vpc_id = module.ec2_remote_instance_vpc.vpc_id

  tags = var.tags
}

# ssh許可
resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_connect_endpoint_security_group_egress_rule_ssh" {
  security_group_id = aws_security_group.ec2_remote_instance_connect_endpoint.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# RDP
resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_security_group_egress_rule_rdp" {
  security_group_id = aws_security_group.ec2_remote_instance_connect_endpoint.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "27" # rdp cf. https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
}
