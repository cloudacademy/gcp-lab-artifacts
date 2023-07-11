provider "google" {
  project = var.project_name
  region  = var.region
  zone    = var.zone
}

#----------------------------------------------------------------------------------------------
#  CLOUD SOURCE REPOSITORY
#      - Create Repository
#----------------------------------------------------------------------------------------------

resource "google_sourcerepo_repository" "api_repo" {
  name = var.api_repository_name
}

#----------------------------------------------------------------------------------------------
#  CLOUD BUILD
#      - Create Build Trigger
#----------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  name        = var.api_repository_name
  description = "Cloud Source Repository Trigger ${var.api_repository_name}"
  trigger_template {
    repo_name   = var.api_repository_name
    branch_name = var.branch_name
  }

  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY   = var.app_name
    _SERVICE_NAME = var.api_service_name
    _REGION       = var.region
    _ZONE         = "us-central1-b"
    _CLUSTER      = "lab-cluster"
  }

  depends_on = [google_sourcerepo_repository.api_repo]
}

#----------------------------------------------------------------------------------------------
#  ARTIFACT REGISTRY
#      - Create Registry
#----------------------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "app-repo" {
  location      = "us-central1"
  repository_id = "var.app_name"
  description   = "Docker repository for app images"
  format        = "DOCKER"
}

#----------------------------------------------------------------------------------------------
#  CLOUD RUN
#      - Create Service
#      - Expose the service to the public
#----------------------------------------------------------------------------------------------

# resource "google_cloud_run_service" "my-service" {
#   name = var.service_name
#   location = var.region

#   template  {
#     spec {
#       containers {
#         image = "gcr.io/cloudacademy-labs-support/ops-app"
#       }
#     }
#   }
# }

# resource "google_cloud_run_service_iam_member" "allUsers" {
#   service  = google_cloud_run_service.my-service.name
#   location = google_cloud_run_service.my-service.location
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }


#----------------------------------------------------------------------------------------------
#  Grant Cloud Build Permission
#----------------------------------------------------------------------------------------------

data "google_project" "project" {
}

resource "google_project_iam_binding" "binding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/cloudfunctions.admin"
}

resource "google_project_iam_binding" "artifactregistrybinding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/artifactregistry.writer"
}

resource "google_project_iam_binding" "sa" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/iam.serviceAccountUser"
}

resource "google_project_iam_binding" "gkebinding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/container.developer"
}


#----------------------------------------------------------------------------------------------
#  Creating Local for image name
#----------------------------------------------------------------------------------------------

# locals {
#   image_name = var.image_name == "" ? "${var.region}/gcr.io/${var.project_name}/${var.service_name}" : var.image_name
# }
