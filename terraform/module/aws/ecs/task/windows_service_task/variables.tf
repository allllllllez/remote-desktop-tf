variable "service_name" {
  type        = string
  description = "service name"
}

variable "cluster_id" {
  type        = string
  description = "cluster id(must be Windows)"
}

variable "task_instance_profile_name" {
  type        = string
  description = "name of instance profile for cluster"
}

variable "tag_name" {
  type        = string
  description = "tag name"
}
