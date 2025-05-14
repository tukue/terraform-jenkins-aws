output "domain_id" {
  value = aws_route53domains_registered_domain.domain.id
}

output "hosted_zone_id" {
  value = aws_route53_zone.primary.zone_id
}

output "name_servers" {
  value = aws_route53_zone.primary.name_servers
}