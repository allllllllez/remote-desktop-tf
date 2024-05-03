variable "my_ip_address" {
  type        = string
  description = "my IP Address. VAR_TF_my_ip_address で指定"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "key_name" {
  type        = string
  description = "EC2 keypair name"
}

variable "instance_type" {
  type        = string
  description = "instance type"
  default     = "mac1.metal" # 1択なんですの
}

variable "vnc_password" {
  type        = string
  description = "VNC password"
}

variable "tags" {
  type = object({
    Name = string,
    User = string
  })
  description = "tag(name, User)"
}
