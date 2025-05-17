# VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_config.name
  }
}

# Subnets
resource "aws_subnet" "main" {
  for_each = var.subnet_config

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = try(each.value.public, false)

  tags = {
    Name = each.key
    Type = try(each.value.public, false) ? "public" : "private"
  }
}

# Internet Gateway (only if public subnets exist)
resource "aws_internet_gateway" "main" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_config.name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_config.name}-public-rt"
  }
}

# Default route for public subnets
resource "aws_route" "public_internet_gateway" {
  count                  = length(local.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# NAT Gateway (optional - uncomment if needed)
# resource "aws_nat_gateway" "main" {
#   count         = length(local.private_subnets) > 0 ? 1 : 0
#   allocation_id = aws_eip.nat[0].id
#   subnet_id     = aws_subnet.main[keys(local.public_subnets)[0]].id
#   tags = {
#     Name = "${var.vpc_config.name}-nat"
#   }
# }

# Private Route Table (optional - uncomment if needed)
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "${var.vpc_config.name}-private-rt"
#   }
# }

# Locals for better organization
locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if try(config.public, false)
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if !try(config.public, false)
  }

  # For outputs
  public_subnet_output = {
    for key, config in local.public_subnets : key => {
      subnet_id = aws_subnet.main[key].id
      az        = aws_subnet.main[key].availability_zone
      cidr      = aws_subnet.main[key].cidr_block
    }
  }

  private_subnet_output = {
    for key, config in local.private_subnets : key => {
      subnet_id = aws_subnet.main[key].id
      az        = aws_subnet.main[key].availability_zone
      cidr      = aws_subnet.main[key].cidr_block
    }
  }
}