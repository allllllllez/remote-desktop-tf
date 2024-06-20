# 
# start EC2
# 
# requirements:
#     * AWS credential
# 

# 
# EC2 instance
# 

# Windows
module "windows_ec2_instance" {
  source        = "./module/aws/ec2_remote_instance"
  my_ip_address = var.my_ip_address
  # ami_name_patterns = ["Windows_Server-2022-English-Full-Base*"]
  ami_name_patterns = ["al2023-ami-2023.2.20230920.1-kernel-6.1-x86_64"]
  user_data_script  = "${path.root}/user_data_linux.sh"
  instance_type     = "r5.4xlarge"
  key_name          = var.key_name
  tags              = local.tags
}

# Mac OS
# module "mac_ec2_instance" {
#   source        = "./module/aws/ec2_mac"
#   my_ip_address = var.my_ip_address
#   key_name      = var.key_name
#   tags          = local.tags
# }
