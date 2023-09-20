# 
# start EC2
# 
# requirements:
#     * AWS credential
# 

# 
# VPC
#
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# Security group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Security group for Windows Server"
  vpc_id      = module.ec2_vpc.vpc_id

  # ご自宅のみ
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  # 雑多な用途であちこちにアクセスする用
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

module "ec2_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                 = "ec2_vpc"
  cidr                 = var.vpc_cidr
  enable_dns_hostnames = true
  create_vpc           = true

  azs            = ["us-west-2a"]
  public_subnets = [cidrsubnet(var.vpc_cidr, 8, 0)]
  # public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  # private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  # aws_route_table_association てきなものがない
  public_subnet_tags = {
    Name = var.tag_name
  }

  tags = local.tags
}

# 
# EC2 keypair
# 
module "ec2_keypair" {
  source   = "./module/aws/ec2_keypair"
  key_name = var.key_name
}

# 
# EC2 instance
# 

# Windows
module "windows_ec2_instance" {
  source = "./module/aws/ec2_windows"

  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]
  subnet_id = module.ec2_vpc.public_subnets[0]

  key_name = module.ec2_keypair.key_pair_name

  tags = local.tags
}
