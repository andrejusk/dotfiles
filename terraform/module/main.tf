locals {
  fqdn = "${var.domain}."
}

# =================================================================
# Public bucket for static content with uploader service account
# =================================================================
resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
}

resource "google_service_account" "uploader_sa" {
  account_id   = "${var.prefix}-uploader-sa"
  display_name = "Uploader Service Account"
}

resource "google_storage_bucket" "bucket" {
  name       = var.domain
  depends_on = [google_project_service.storage]

  location = var.gcs_location
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_acl" "bucket_acl" {
  bucket = google_storage_bucket.bucket.name

  role_entity = [
    "READER:allUsers",
    "OWNER:user-${google_service_account.uploader_sa.email}",
  ]
}

resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  source = "${path.module}/public/index.html"
  bucket = google_storage_bucket.bucket.name
}

# =================================================================
# Expose bucket via HTTPS using Cloud CDN
#
# Adapted from
# https://medium.com/cognite/configuring-google-cloud-cdn-with-terraform-ab65bb0456a9
# =================================================================
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_compute_backend_bucket" "backend" {
  name       = "${var.prefix}-backend"
  depends_on = [google_project_service.compute]

  bucket_name = google_storage_bucket.bucket.name
  description = "Bucket backend for serving static content through CDN"
  enable_cdn  = true
}

resource "google_compute_url_map" "urlmap" {
  name            = "${var.prefix}-urlmap"
  description     = "URL map to bucket backend service"
  default_service = google_compute_backend_bucket.backend.self_link
}

resource "google_compute_managed_ssl_certificate" "certificate" {
  name       = "${var.prefix}-certificate"
  depends_on = [google_project_service.compute]

  managed {
    domains = [local.fqdn]
  }
}

resource "google_compute_target_https_proxy" "https" {
  name             = "${var.prefix}-https-proxy"
  url_map          = google_compute_url_map.urlmap.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.self_link]
}

resource "google_compute_global_address" "ipv4" {
  name       = "${var.prefix}-ipv4"
  depends_on = [google_project_service.compute]

  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_global_address" "ipv6" {
  name       = "${var.prefix}-ipv6"
  depends_on = [google_project_service.compute]

  ip_version   = "IPV6"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "fwd_ipv4" {
  name       = "${var.prefix}-fwd-ipv4"
  target     = google_compute_target_https_proxy.https.self_link
  ip_address = google_compute_global_address.ipv4.address
  port_range = "443"
}

resource "google_compute_global_forwarding_rule" "fwd_ipv6" {
  name       = "${var.prefix}-fwd-ipv6"
  target     = google_compute_target_https_proxy.https.self_link
  ip_address = google_compute_global_address.ipv6.address
  port_range = "443"
}

resource "google_dns_record_set" "dns_a_record" {
  name         = local.fqdn
  managed_zone = var.dns_zone

  type    = "A"
  ttl     = var.dns_ttl
  rrdatas = [google_compute_global_address.ipv4.address]
}

resource "google_dns_record_set" "dns_aaaa_record" {
  name         = local.fqdn
  managed_zone = var.dns_zone

  type    = "AAAA"
  ttl     = var.dns_ttl
  rrdatas = [google_compute_global_address.ipv6.address]
}
