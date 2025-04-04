terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.28.0"
    }
  }
  required_version = ">= 1.0.0"
}

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

  filename = "cloudbuild.yaml"
  substitutions = {
    _SERVICE_NAME= var.service_name
    _REGION = var.region
    _BUCKET_NAME = var.bucket_name
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
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_project_iam_binding" "storage_pubsub" {
  project = var.project_name
  members  = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  role    = "roles/pubsub.publisher"
}

resource "google_project_service_identity" "pubsub_sa" {
  provider = google-beta
  project  = var.project_name
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_member" "pubsub_token_creator" {
  project = var.project_name
  member  = google_project_service_identity.pubsub_sa.member
  role    = "roles/iam.serviceAccountTokenCreator"
}

data "google_compute_default_service_account" "default" {
}

resource "google_project_iam_binding" "compute_eventarc" {
  project = var.project_name
  members  = ["serviceAccount:${data.google_compute_default_service_account.default.email}"]
  role    = "roles/eventarc.eventReceiver"
}

resource "google_project_service_identity" "cloudbuild_sa" {
  provider = google-beta
  project  = var.project_name
  service  = "cloudbuild.googleapis.com"
}

resource "google_project_iam_member" "cloudbuild_sa_run_admin" {
  project = var.project_name
  member  = google_project_service_identity.cloudbuild_sa.member
  role    = "roles/run.admin"
}

resource "google_project_iam_member" "cloudbuild_sa_user" {
  project = var.project_name
  member  = google_project_service_identity.cloudbuild_sa.member
  role    = "roles/iam.serviceAccountUser"
}

#----------------------------------------------------------------------------------------------
#  Creating Local for image name
#----------------------------------------------------------------------------------------------

locals {
  image_name = var.image_name == "" ? "${var.region}/gcr.io/${var.project_name}/${var.service_name}": var.image_name
}