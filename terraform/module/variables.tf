variable "prefix" {
  description = "Resource prefix"
  default     = "dots"
}

variable "project" {
  type        = string
  description = "Google Cloud project to host resources in"
}

variable "project_number" {
  type        = string
  description = "The numeric project ID"
}

variable "domain" {
  description = "DNS name to serve static content"
  type        = string
}

variable "dns_zone" {
  description = "Cloud DNS zone to use"
  type        = string
}

variable "gcs_location" {
  type        = string
  description = "Google Stoage location to provision resources in"
  default     = "EU" # Multi-region, Europe
}

variable "dns_ttl" {
  type        = number
  description = "DNS TTL to use for records"
  default     = 3600
}
