variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" { type = string }

variable "zone" {
  type = string
}

variable "project_name" {
  type = string
}

variable "org_id" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "apis" {
  type = list(string)
}

variable "container_registry_repository_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "gke_name" {
  type = string
}
