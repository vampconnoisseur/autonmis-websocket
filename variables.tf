variable "region" {
  type        = string
  description = "The name of region."
}

variable "username" {
  type        = string
  description = "The name of user."
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster."
}

variable "hosted_zone_id" {
  type        = string
  description = "The name of the record."
}

variable "subdomain" {
  type        = string
  description = "The name of the subdomain for user."
}

variable "task_definition" {
  type        = string
  description = "The family name of the ECS task definition."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the ALB is located."
}

variable "subnets" {
  type        = list(string)
  description = "The list of subnets for the ALB."
}