
variable "project_id" {
  type        = string
  description = "Project Id"
  default     = "<projectid>"
}

variable "instance_name" {
  type        = string
  description = "instance name"
  default     = "http-status"
}

variable "region" {
  type        = string
  description = "region to deploy"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "zone to deploy"
  default     = "us-central1-a"
}