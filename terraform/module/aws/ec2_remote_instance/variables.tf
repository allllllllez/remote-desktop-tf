variable "my_ip_address" {
  type        = string
  description = "my IP Address. VAR_TF_my_ip_address で指定"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
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

variable "cluster_name" {
  type        = string
  description = "cluster name"
  default     = "windows"
}

variable "tags" {
  type = object({
    Name = string,
    User = string
  })
  description = "tag(name, User)"
}
