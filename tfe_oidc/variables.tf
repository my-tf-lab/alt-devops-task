variable "organization_name" {
  description = "the name of the organization in terraform cloud"
  default     = "tetheus-corp"
}

variable "project_name" {
  description = "the name of the project in terraform cloud"
  default     = "Default Project"
}

variable "workspace_name" {
  description = "the name of the project in terraform cloud"
  default     = "*"
}

variable "audience" {
  description = "the name of the audience used by terraform cloud"
  default     = "aws.workload.identity"
}
