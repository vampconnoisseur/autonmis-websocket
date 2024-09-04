variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster."
}

variable "task_definition" {
  type        = string
  description = "The family name of the ECS task definition."
}

variable "subnets" {
  type        = list(string)
  description = "The list of subnets for the ECS service."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the ALB is located."
}

variable "alb_arn" {
  type        = string
  description = "The ARN of the ALB."
}

variable "alb_sg_id" {
  type        = string
  description = "The security group ID for the ALB."
}