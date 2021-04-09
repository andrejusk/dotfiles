variable "project" {
  description = "Google Cloud project to host resources in"
  type        = string
}

variable "domain" {
  description = "DNS name to serve static content"
  type        = string
}

variable "dns_zone" {
  description = "Cloud DNS zone to use"
  type        = string
}
