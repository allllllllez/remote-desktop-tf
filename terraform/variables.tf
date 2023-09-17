# ローカル環境のIPアドレス。vars.tfvars に書いておく?
variable "my_ip_address" {
  type        = string
  description = "my IP Address"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = "windows"
}

variable "tag_name" {
  type        = string
  description = "tag name"
  default     = "windows_server"
}

variable "key_name" {
  type        = string
  description = "EC2 keypair name"
  default     = "windows_server"
}
