variable "main_vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}


variable "tags" {}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
}

variable "firewall_subnet_cidrs" {
  description = "List of CIDR blocks for firewall subnets"
  type        = list(string)
}

variable "nat_gw_enabled" {
  description = "Enable or disable NAT Gateway"
  type        = bool
  default     = false
}

variable "firewall_enabled" {
  description = "Enable or disable AWS Network Firewall"
  type        = bool
  default     = false
}

variable "allowed_domains" {
  description = "List of allowed domains"
  type        = list(string)
}