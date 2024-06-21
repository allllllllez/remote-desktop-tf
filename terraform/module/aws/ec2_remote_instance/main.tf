# 
# EC2 + Security Group in VPC を立てる
# ssh 接続には EC2 Instance Connect Endpoint を使用する
# HTTP:80 は ALB 経由でアクセス可能

###############################################################################
# VPC
###############################################################################

# VPC
module "ec2_remote_instance_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name                 = "${var.prefix_name}-${var.env}"
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

###############################################################################
# 
# ALB
#
###############################################################################

# ALB Internet -> EC2 instance (HTTP:80)
resource "aws_lb" "ec2_remote_instance_alb" {
  name               = "${var.prefix_name}-${var.env}-http-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.ec2_remote_instance_alb_security_group.id
  ]
  subnets = module.ec2_remote_instance_vpc.public_subnets

  # enable_deletion_protection = true

  tags = var.tags
}

resource "aws_lb_listener" "ec2_remote_instance_alb_listener" {
  load_balancer_arn = aws_lb.ec2_remote_instance_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_remote_instance_alb_target_group.arn
  }
}

resource "aws_lb_target_group" "ec2_remote_instance_alb_target_group" {
  name     = "${var.prefix_name}-${var.env}-http-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.ec2_remote_instance_vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "ec2_remote_instance_alb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.ec2_remote_instance_alb_target_group.arn
  target_id        = aws_instance.ec2_remote_instance.id
}

# ALB の Security group
resource "aws_security_group" "ec2_remote_instance_alb_security_group" {
  name        = "${var.prefix_name}-${var.env}-http-alb-both-rule"
  description = "Security group for ALB"
  vpc_id      = module.ec2_remote_instance_vpc.vpc_id

  tags = var.tags
}

# 指定IPからのhttpのみ許可する
resource "aws_vpc_security_group_ingress_rule" "ec2_remote_instance_alb_security_group_ingress_rule_http" {
  security_group_id = aws_security_group.ec2_remote_instance_alb_security_group.id
  cidr_ipv4         = var.my_ip_address
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# EC2 を含むすべての送信先に対して HTTP:80 を許可
resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_alb_security_group_egress_rule_http" {
  security_group_id = aws_security_group.ec2_remote_instance_alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

###############################################################################
# 
# EC2 
# 
###############################################################################

data "aws_ami" "ec2_remote_instance_ami" {
  most_recent        = true
  include_deprecated = true
  filter {
    name   = "name"
    values = var.ami_name_patterns
  }
}

resource "aws_instance" "ec2_remote_instance" {
  key_name      = "${var.prefix_name}-${var.env}-instance"
  ami           = data.aws_ami.ec2_remote_instance_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2_remote_instance_security_group.id
  ]

  subnet_id                   = module.ec2_remote_instance_vpc.public_subnets[0]
  associate_public_ip_address = true

  # インスタンス起動時に実行するscript
  user_data = file(var.user_data_script)
  root_block_device {
    volume_size           = 200
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = "true"
  }

  tags = var.tags
}

# EC2 の Security group
resource "aws_security_group" "ec2_remote_instance_security_group" {
  name        = "${var.prefix_name}-${var.env}-instance-both-rule"
  description = "Security group for Windows Server"
  # description = "Security group for EC2"
  vpc_id = module.ec2_remote_instance_vpc.vpc_id

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

# albからのhttpのみ許可する
resource "aws_vpc_security_group_ingress_rule" "ec2_remote_instance_security_group_ingress_rule_http" {
  security_group_id            = aws_security_group.ec2_remote_instance_security_group.id
  referenced_security_group_id = aws_security_group.ec2_remote_instance_alb_security_group.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# 指定IPからのRDPのみ許可する（Windows用）
# TODO: 2回目以降のApplyで「InvalidParameterValue: You may only specify specific ports for TCP, UDP, ICMP, and ICMPv6 protocol rules.」って絶対言われる
# resource "aws_vpc_security_group_ingress_rule" "ec2_remote_instance_security_group_ingress_rule_rdp" {
#   security_group_id = aws_security_group.ec2_remote_instance_security_group.id
#   cidr_ipv4         = var.my_ip_address
#   from_port         = 3389
#   to_port           = 3389
#   ip_protocol       = "27" # rdp cf. https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# }

# 外部への通信を許可
resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_security_group_egress_rule_all" {
  security_group_id = aws_security_group.ec2_remote_instance_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EC2 で yum を使用するために S3 VPC ゲートウェイエンドポイントを立てる
# cf. https://repost.aws/ja/knowledge-center/ec2-al1-al2-update-yum-without-internet
resource "aws_vpc_endpoint" "ec2_remote_instance_vpc_endpoint_s3" {
  vpc_id            = module.ec2_remote_instance_vpc.vpc_id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.ec2_remote_instance_vpc.private_route_table_ids
  tags              = var.tags
}

###############################################################################
# 
# EC2 instance connect endpoint
# 
###############################################################################

resource "aws_ec2_instance_connect_endpoint" "ec2_remote_instance_connect_endpoint" {
  subnet_id          = module.ec2_remote_instance_vpc.private_subnets[0]
  security_group_ids = [aws_security_group.ec2_remote_instance_connect_endpoint.id]
  preserve_client_ip = true

  tags = var.tags
}

# EC2 instance connect endpoint 用 Security group
resource "aws_security_group" "ec2_remote_instance_connect_endpoint" {
  name   = "${var.prefix_name}-${var.env}-instance-connect-endpoint-egress-rule"
  vpc_id = module.ec2_remote_instance_vpc.vpc_id

  tags = var.tags
}

# ssh許可
resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_connect_endpoint_security_group_egress_rule_ssh" {
  security_group_id = aws_security_group.ec2_remote_instance_connect_endpoint.id
  cidr_ipv4         = "0.0.0.0/0"
  # cidr_ipv4         = var.my_ip_address
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# 指定IPからのRDPのみ許可する（Windows用）
# TODO: 2回目以降のApplyで「InvalidParameterValue: You may only specify specific ports for TCP, UDP, ICMP, and ICMPv6 protocol rules.」って絶対言われる
# resource "aws_vpc_security_group_egress_rule" "ec2_remote_instance_security_group_egress_rule_rdp" {
#   security_group_id = aws_security_group.ec2_remote_instance_connect_endpoint.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 3389
#   to_port           = 3389
#   ip_protocol       = "27" # rdp cf. https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# }
