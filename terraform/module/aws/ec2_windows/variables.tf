variable "vpc_security_group_ids" {
  type        = list(any)
  description = "list of security group id"
}

variable "subnet_id" {
  type        = string
  description = "subnet id"
}

variable "key_name" {
  type        = string
  description = "EC2 keypair name"
}

variable "instance_type" {
  type        = string
  description = "instance type"
  default     = "t2.micro" # ほぼタダになるスペック
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
