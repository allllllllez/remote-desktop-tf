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

variable "ami" {
  type        = string
  description = "EC2 AMI. default: Microsoft Windows Server 2022 at us-west-2"
  default     = "ami-07e70003c665fb5f3"
  # Microsoft Windows Server 2022 Base with Containers / ap-northeast-1
  # default = "ami-0cead27965999bdc5"
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
