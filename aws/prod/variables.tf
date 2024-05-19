locals {
  project = "sprint"
}

variable "subnet_1a" {}
variable "subnet_1b" {}
variable "subnet_1c" {}

variable "projectsprint_vm_public_key" {
  type    = string
  default = ""
}

variable "projectsprint_start" {
  type    = bool
  default = false
}

variable "projectsprint_start_db" {
  type    = bool
  default = false
}

variable "projectsprint_start_ecs" {
  type    = bool
  default = false
}

variable "projectsprint_db_password" {
  type    = string
  default = ""
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

