provider "google" {
  project = var.project_name
  region  = var.region
  zone    = var.zone
}

#----------------------------------------------------------------------------------------------
#  CLOUD SOURCE REPOSITORY
#      - Create Repositories
#----------------------------------------------------------------------------------------------

resource "google_sourcerepo_repository" "api_repo" {
  name = var.api_repository_name
}

resource "google_sourcerepo_repository" "votes_repo" {
  name = var.votes_repository_name
}

resource "google_sourcerepo_repository" "upvote_repo" {
  name = var.upvote_repository_name
}

resource "google_sourcerepo_repository" "votes_function_repo" {
  name = var.votes_function_repository_name
}

resource "google_sourcerepo_repository" "upvote_function_repo" {
  name = var.upvote_function_repository_name
}

#----------------------------------------------------------------------------------------------
#  CLOUD BUILD
#      - Create Build Triggers
#----------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "api_cloud_build_trigger" {
  name        = var.api_repository_name
  description = "Cloud Source Repository Trigger ${var.api_repository_name}"
  trigger_template {
    repo_name   = var.api_repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY   = var.app_name
    _SERVICE_NAME = var.api_service_name
    _REGION       = var.region
    _ZONE         = "us-central1-b"
    _CLUSTER      = "lab-cluster"
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  }

  depends_on = [google_sourcerepo_repository.api_repo]
}

resource "google_cloudbuild_trigger" "votes_cloud_build_trigger" {
  name        = var.votes_repository_name
  description = "Cloud Source Repository Trigger ${var.votes_repository_name}"
  trigger_template {
    repo_name   = var.votes_repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY   = var.app_name
    _SERVICE_NAME = var.votes_service_name
    _REGION       = var.region
    _ZONE         = "us-central1-b"
    _CLUSTER      = "lab-cluster"
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  }

  depends_on = [google_sourcerepo_repository.votes_repo]
}

resource "google_cloudbuild_trigger" "upvote_cloud_build_trigger" {
  name        = var.upvote_repository_name
  description = "Cloud Source Repository Trigger ${var.upvote_repository_name}"
  trigger_template {
    repo_name   = var.upvote_repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY   = var.app_name
    _SERVICE_NAME = var.upvote_service_name
    _REGION       = "us-central"
    _ZONE         = "us-central1-b"
    _CLUSTER      = "lab-cluster"
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  }

  depends_on = [google_sourcerepo_repository.upvote_repo]
}

resource "google_cloudbuild_trigger" "votes_function_cloud_build_trigger" {
  name        = var.votes_function_repository_name
  description = "Cloud Source Repository Trigger ${var.votes_function_repository_name}"
  trigger_template {
    repo_name   = var.votes_function_repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY     = var.app_name
    _SERVICE_NAME   = var.votes_function_service_name
    _REGION         = var.region
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  }

  depends_on = [google_sourcerepo_repository.votes_function_repo]
}

resource "google_cloudbuild_trigger" "upvote_function_cloud_build_trigger" {
  name        = var.upvote_function_repository_name
  description = "Cloud Source Repository Trigger ${var.upvote_function_repository_name}"
  trigger_template {
    repo_name   = var.upvote_function_repository_name
    branch_name = var.branch_name
  }
  service_account = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  filename = "cloudbuild.yaml"
  substitutions = {
    _REPOSITORY   = var.app_name
    _SERVICE_NAME = var.upvote_function_service_name
    _REGION       = var.region
    _BUCKET_NAME = var.bucket_name
    _SERVICE_ACCOUNT = "projects/${var.project_name}/serviceAccounts/${var.project_name}-init@${var.project_name}.iam.gserviceaccount.com"
  }

  depends_on = [google_sourcerepo_repository.upvote_function_repo]
}

#----------------------------------------------------------------------------------------------
#  ARTIFACT REGISTRY
#      - Create Registry
#----------------------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "app-repo" {
  location      = "us-central1"
  repository_id = var.app_name
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
#  Grant Permissions
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

resource "google_project_iam_binding" "ingressListBinding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/compute.networkViewer"
}

resource "google_project_iam_binding" "ingressListBinding" {
  project = var.project_name
  members = ["serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"]
  role    = "roles/storage.admin"
}
