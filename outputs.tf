# VPC Output
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

# Subnet Outputs
output "public_subnets" {
  description = "Map of public subnets with their IDs and AZs"
  value       = local.public_subnet_output
}

output "private_subnets" {
  description = "Map of private subnets with their IDs and AZs"
  value       = local.private_subnet_output
}

# Additional detailed outputs
output "public_subnet_ids" {
  description = "Map of just public subnet IDs"
  value       = { for k, v in local.public_subnet_output : k => v.subnet_id }
}

output "private_subnet_ids" {
  description = "Map of just private subnet IDs"
  value       = { for k, v in local.private_subnet_output : k => v.subnet_id }
}

output "public_subnet_azs" {
  description = "Map of public subnet availability zones"
  value       = { for k, v in local.public_subnet_output : k => v.az }
}