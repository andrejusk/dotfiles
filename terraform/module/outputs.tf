output "bucket_url" {
    value = "storage.googleapis.com/${var.domain}"
}

output "bucket_link" {
    value = google_storage_bucket.bucket.self_link
}
