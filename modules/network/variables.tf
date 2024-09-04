variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the ALB is located."
}

variable "subnets" {
  type        = list(string)
  description = "The list of subnets for the ALB."
}