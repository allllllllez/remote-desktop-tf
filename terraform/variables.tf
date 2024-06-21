variable "env" {
  type        = string
  description = "環境名"

}

variable "prefix_name" {
  type        = string
  description = "リソース名のプレフィックス"

}

variable "my_ip_address" {
  type        = string
  description = "my IP Address"
}

variable "tag_name" {
  type        = string
  description = "tag name"
}

variable "user_name" {
  type        = string
  description = "User name"
}

variable "vnc_password" {
  type        = string
  description = "VNC password"
}
