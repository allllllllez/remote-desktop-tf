variable "my_ip_address" {
  type        = string
  description = "my IP Address. VAR_TF_my_ip_address で指定"
}

variable "vpc_cidr" {
  type        = string
  description = "default: 10.0.0.0/16 (10.0.0.1 - 10.0.255.255)"
  default     = "10.0.0.0/16"
}

variable "key_name" {
  type        = string
  description = "EC2 keypair name"
}

variable "azs" {
  type        = list(string)
  description = "アベイラビリティゾーン"
  default     = ["us-west-2a"]
}

variable "ami_name_patterns" {
  type        = list(string)
  description = "EC2 AMI name pattern"
}

variable "instance_type" {
  type        = string
  description = "instance type. defailt: ほぼタダになるインスタンスタイプ"
  default     = "t2.micro"
}

variable "user_data_script" {
  type        = string
  description = "EC2 startup script path"
  default     = ""
}

variable "tags" {
  type = object({
    Name = string,
    User = string
  })
  description = "tag(name, User)"
}
