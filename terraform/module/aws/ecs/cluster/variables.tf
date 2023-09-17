variable "cluster_name" {
  type        = string
  description = "name of cluster"
}

variable "cluster_role_name" {
  type        = string
  description = "name of IAM role for cluster"
}

variable "cluster_instance_profile_name" {
  type        = string
  description = "name of instance profile for cluster"
}

variable "tag_name" {
  type        = string
  description = "tag name"
}
