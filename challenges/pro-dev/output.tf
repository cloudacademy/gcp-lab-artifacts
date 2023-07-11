output "project_id" {
  value = var.project_name
}

output "url" {
  value = "${google_cloud_run_service.my-service.status[0].url}"
}

output "api_repository_http_url" {
  description = "HTTP URL of the repository in Cloud Source Repositories."
  value       = google_sourcerepo_repository.api_repo.url
}
