provider "google" {
  project = var.project_name
  region = var.region
  zone = var.zone
}

#----------------------------------------------------------------------------------------------
#  CLOUD SOURCE REPOSITORY
#      - Create Repository
#----------------------------------------------------------------------------------------------

resource "google_sourcerepo_repository" "repo" {
  name = var.repository_name
}

#----------------------------------------------------------------------------------------------
#  CLOUD BUILD
#      - Create Build Trigger
#----------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "trigger" {
  name = var.repository_name
  trigger_template {
    repo_name = var.repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-sa@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _SERVICE_NAME= var.service_name
    _REGION = var.region
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-sa@${var.project_name}.iam.gserviceaccount.com"
  }
}

#----------------------------------------------------------------------------------------------
#  ARTIFACT REGISTRY
#      - Create Registry
#----------------------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "repo" {
  location      = "us-central1"
  repository_id = var.repository_name
  format        = "DOCKER"
}

#----------------------------------------------------------------------------------------------
#  CLOUD RUN
#      - Create Service
#      - Expose the service to the public
#----------------------------------------------------------------------------------------------

resource "google_cloud_run_service" "my-service" {
  name = var.service_name
  location = var.region

  template  {
    spec {
      containers {
        image = "gcr.io/cloudacademy-labs-support/ops-app"
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.my-service.name
  location = google_cloud_run_service.my-service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

#----------------------------------------------------------------------------------------------
#  Creating Local for image name
#----------------------------------------------------------------------------------------------

locals {
  image_name = var.image_name == "" ? "${var.region}/gcr.io/${var.project_name}/${var.service_name}": var.image_name
}