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

variable "bastion_az" {
  description = "Availability Zone index for the bastion host"
  type        = number
}

variable "nacl_enabled" {
  description = "Enable or disable Network ACL"
  type        = bool
  default     = false
}

variable "home_ip_cidr" {
  description = "CIDR block for my home IP"
  type        = string
}