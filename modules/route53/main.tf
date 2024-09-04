# Create a CNAME record for the ALB
resource "aws_route53_record" "cname" {
  zone_id = var.hosted_zone_id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}

output "subdomain_url" {
  value = aws_route53_record.cname.fqdn
}