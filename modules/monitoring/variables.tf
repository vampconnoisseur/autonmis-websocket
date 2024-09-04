variable "alb_arn" {
  type        = string
  description = "The ARN of the ALB."
}

variable "alb_suffix" {
  type        = string
  description = "The suffix of the ALB ARN."
}

variable "region" {
  type        = string
  description = "The AWS region."
}

variable "username" {
  type        = string
  description = "The username to be used."
}