# 
# start EC2
# 
# requirements:
#     * AWS credential (profile:dedh004)
# 

locals {
  user_data_git_win = <<-EOF
  <powershell>
  Initialize-ECSAgent -Cluster ${var.cluster_name} -EnableTaskIAMRole -LoggingDrivers '["json-file","awslogs"]'
  # Git
  # get latest download url for git-for-windows 64-bit exe
  $git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"
  echo "git_url: "$git_url
  echo "asset: "$asset

  # download installer
  $installer = "$env:temp\$($asset.name)"
  echo "installer: "$installer 
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer

  # inf file
  # https://github.com/git-for-windows/git/wiki/Silent-or-Unattended-Installation
  $git_install_inf = "$env:temp\setup.inf"
  Set-Content -Path "$git_install_inf" -Force -Value @'
  [Setup]
  Lang=default
  Dir=C:\Git
  Group=Git
  NoIcons=0
  SetupType=default
  Components=
  Tasks=
  PathOption=Cmd
  SSHOption=OpenSSH
  CRLFOption=CRLFCommitAsIs
  '@

  # run installer
  $install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
  Start-Process -FilePath $installer -ArgumentList $install_args -Wait

  # Add git path
  $ENV:Path="C:\Git\bin;"+$ENV:Path

  </powershell>
  <persist>true</persist>
  EOF
}

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

  tags = {
    Name = var.tag_name
  }
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

  # create_igw = true

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  # default_route_table_routes = [
  #   {
  #     cidr_block = "0.0.0.0/0"
  #     # gateway_id = igw_id
  #   }
  # ]

  # default_route_table_tags = {
  #   Name = var.tag_name
  # }

  # aws_route_table_association てきなものがない
  public_subnet_tags = {
    Name = var.tag_name
  }

  tags = {
    Name = var.tag_name
  }
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
resource "aws_instance" "ec2_insecre" {
  instance_type = "t2.small"

  # Windows_Server-2019-English-Full-ECS_Optimized-2021.02.10 →  Error launching source instance: AuthFailure: Not authorized for images: [ami-0f0cd3f9f601e909e]
  # ami = "ami-0f0cd3f9f601e909e"
  # Microsoft Windows Server 2022 Base with Containers / ap-northeast-1
  # ami = "ami-0cead27965999bdc5"
  # us-west-2 にある
  ami = "ami-07e70003c665fb5f3"
  # Security group

  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]
  associate_public_ip_address = true
  subnet_id                   = module.ec2_vpc.public_subnets[0]

  # インスタンス起動時に実行するscript
  user_data = base64encode(local.user_data_git_win)
  key_name  = module.ec2_keypair.key_pair_name

  tags = {
    Name = var.tag_name
  }
}
