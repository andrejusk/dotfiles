# Static bucket
resource "google_storage_bucket" "bucket" {
  provider = google-beta

  project = var.project

  name          = var.domain
  location      = "EU"
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = var.enable_versioning
  }
}

# Allow public read
resource "google_storage_default_object_acl" "bucket_acl" {
  provider    = google-beta
  bucket      = google_storage_bucket.bucket.name
  role_entity = ["READER:allUsers"]
}

# DNS entry
resource "google_dns_record_set" "cname" {
  provider = google-beta

  depends_on = [google_storage_bucket.bucket]

  project = var.project

  name         = "${var.domain}."
  managed_zone = var.dns_zone
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["c.storage.googleapis.com."]
}
