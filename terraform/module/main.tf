locals {
  fqdn = "${var.domain}."
}

# =================================================================
# Public bucket for static content with uploader service account
# =================================================================
resource "google_project_service" "storage" {
  disable_on_destroy = false
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
  uniform_bucket_level_access = false
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_acl" "bucket_acl" {
  bucket = google_storage_bucket.bucket.name

  role_entity = [
    "OWNER:project-owners-${var.project_number}",
    "OWNER:project-editors-${var.project_number}",
    "READER:project-viewers-${var.project_number}",
    "OWNER:user-${google_service_account.uploader_sa.email}",
  ]
}

resource "google_storage_default_object_acl" "default_acl" {
  bucket = google_storage_bucket.bucket.name

  role_entity = [
    "READER:allUsers",
    "OWNER:project-owners-${var.project_number}",
    "OWNER:project-editors-${var.project_number}",
    "READER:project-viewers-${var.project_number}",
  ]
}

resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  source = "${path.module}/public/index.html"
  bucket = google_storage_bucket.bucket.name
}

resource "google_dns_record_set" "dns_cname_record" {
  name         = local.fqdn
  managed_zone = var.dns_zone

  type    = "CNAME"
  ttl     = var.dns_ttl
  rrdatas = ["c.storage.googleapis.com."]
}
