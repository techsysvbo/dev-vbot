# output "vpc_id" {
#   description = "VPC ID"
#   value       = aws_vpc.dev_vpc.id
# }

# output "public_subnet_id" {
#   description = "Public Subnet ID"
#   value       = aws_subnet.public_subnet.id
# }

# output "private_subnet_id" {
#   description = "Private Subnet ID"
#   value       = aws_subnet.private_subnet.id
# }

output "grafana_access" {
  value = { for i in aws_instance.dev_main[*] : i.tags.Name => "${i.public_ip}:3000" }
}

output "instance_ips" {
  value = [for i in aws_instance.dev_main[*] : i.public_ip]
}

output "instance_ids" {
  value = [for i in aws_instance.dev_main[*] : i.id]
}