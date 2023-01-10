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

resource "google_cloudbuild_trigger" "cloud_build_trigger" {
  name = var.repository_name
  description = "Cloud Source Repository Trigger ${var.repository_name}"
  trigger_template {
    repo_name = var.repository_name
    branch_name = var.branch_name
  }

  filename = "cloudbuild.yaml"
  substitutions = {
    _SERVICE_NAME= var.service_name
    _REGION = var.region
  }

  depends_on = [google_sourcerepo_repository.repo]
}

#----------------------------------------------------------------------------------------------
#  CONTAINER REGISTRY
#      - Create Registry
#----------------------------------------------------------------------------------------------

resource "google_container_registry" "registry" {
  project  = var.project_name
  location = "us"
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
#  Grant Cloud Build Permission
#----------------------------------------------------------------------------------------------

data "google_project" "project" {
}

resource "google_project_iam_binding" "binding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role = "roles/run.admin"
}

resource "google_project_iam_binding" "sa" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role = "roles/iam.serviceAccountUser"
}


#----------------------------------------------------------------------------------------------
#  Creating Local for image name
#----------------------------------------------------------------------------------------------

locals {
  image_name = var.image_name == "" ? "${var.region}/gcr.io/${var.project_name}/${var.service_name}": var.image_name
}