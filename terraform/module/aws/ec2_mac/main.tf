#
# EC2（キーペア付き） + Security Group in VPC 
#

# 
# VPC
#
# Security group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Security group for Windows Server"
  vpc_id      = module.ec2_vpc.vpc_id

  # 自宅のみ
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  ingress {
    description = "tcp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  ingress {
    description = "tcp"
    from_port   = 5900
    to_port     = 5900
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  tags = var.tags
}

module "ec2_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

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
    Name = var.tags
  }

  tags = var.tags
}

# 
# EC2 keypair
# 
module "ec2_keypair" {
  source   = "./module/aws/ec2_keypair"
  key_name = var.key_name
}



# EC2 (MacOS インスタンス)
resource "aws_instance" "ec2_insecre" {
  # macOS Ventura (us-west-2)
  # ami-0aeabe8f5e20e0abc (64 ビット (Mac)) / ami-0b92232bf62685acf (64 ビット (Mac-Arm))
  # macOS Monterey (us-west-2)
  # ami-0d497e9821ce0442e (64 ビット (Mac)) / ami-0131c541cc9e23d9b (64 ビット (Mac-Arm))
  # macOS Big Sur (us-west-2)
  # ami-0d411cb82ffa41562 (64 ビット (Mac)) / ami-0ccff3aa7571c1146 (64 ビット (Mac-Arm))
  ami = "ami-0aeabe8f5e20e0abc"

  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]
  subnet_id                   = module.ec2_windows_vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name                    = module.ec2_keypair.key_pair_name

  # インスタンス起動時に実行するscript
  # user_data = base64encode(local.user_data_git_win)

  # テナンシーで「専有ホスト」指定必須
  tenancy = "host"
  host_id = aws_ec2_host.mac_host.id

  tags = var.tags
}

# 専有テナンシー
resource "aws_ec2_host" "mac_host" {
  instance_type     = var.instance_type
  availability_zone = "us-west-2a"
  host_recovery     = "on"
  auto_placement    = "on"
}
