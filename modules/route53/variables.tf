variable "hosted_zone_id" {
  type        = string
  description = "The ID of the Route53 hosted zone."
}

variable "subdomain" {
  type        = string
  description = "The name of the subdomain."
}

variable "alb_dns_name" {
  type        = string
  description = "The DNS name of the ALB."
}