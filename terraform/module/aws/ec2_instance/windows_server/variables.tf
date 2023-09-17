variable "vpc_security_group_ids" {
  type        = list(any)
  description = "list of security group id"
}

variable "subnet_id" {
  type        = string
  description = "subnet id"
}

variable "iam_instance_profile" {
  type        = string
  description = "instance profile"
  default     = null
}

variable "user_data" {
  type        = string
  description = "setup script(for Windows, not encoded)"
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

variable "tag_name" {
  type        = string
  description = "tag name"
}
