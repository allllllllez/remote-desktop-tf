# ローカル環境のIPアドレス。vars.tfvars に書いておく?
variable "my_ip_address" {
  type        = string
  description = "my IP Address"
}

variable "tag_name" {
  type        = string
  description = "tag name"
  default     = "windows_server"
}

variable "user_name" {
  type        = string
  description = "User name"
}

variable "key_name" {
  type        = string
  description = "EC2 keypair name"
  default     = "windows_server"
}
