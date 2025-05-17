variable "vpc_config" {
  description = "Configuration for the VPC including CIDR block and name"
  type = object({
    cidr_block = string
    name       = string
  })
  validation {
    condition     = can(cidrhost(var.vpc_config.cidr_block, 0)) # More reliable than cidrnetmask
    error_message = "Must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)"
  }
}

variable "subnet_config" {
  description = "Configuration for subnets including CIDR, AZ, and public flag"
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))
  validation {
    condition = alltrue([
      for k, config in var.subnet_config : 
      can(cidrhost(config.cidr_block, 0)) && contains(["eu-north-1a", "eu-north-1b"], config.az)
    ])
    error_message = "Each subnet must have valid CIDR and AZ in eu-north-1 region"
  }
}