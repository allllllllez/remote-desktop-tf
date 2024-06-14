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
  source        = "./module/aws/ec2_windows"
  my_ip_address = var.my_ip_address
  key_name      = var.key_name
  tags          = local.tags
}

# Mac OS
# module "mac_ec2_instance" {
#   source        = "./module/aws/ec2_mac"
#   my_ip_address = var.my_ip_address
#   key_name      = var.key_name
#   tags          = local.tags
# }
