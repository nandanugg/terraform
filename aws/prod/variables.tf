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

variable "projectsprint_start_db" {
  type    = bool
  default = false
}

variable "projectsprint_start_bucket" {
  type    = bool
  default = false
}

variable "projectsprint_start_load_test" {
  type    = bool
  default = false
}
variable "projectsprint_start_ecs_cluster" {
  type    = bool
  default = false
}
variable "projectsprint_db_password" {
  type    = string
  default = ""
}

variable "rds_ca_cert_path_ap_southeast_1" {
  type    = string
  default = ""
}
variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

