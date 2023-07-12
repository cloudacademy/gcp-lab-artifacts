variable "project_name" {
   description = "The project ID where all resources will be launched."
  type = string
}

variable "region" {
  description = "The location region to deploy the Cloud Run services. Note: Be sure to pick a region that supports Cloud Run."
  type        = string
}

variable "zone" {
  description = "The location zone to deploy the Cloud Run services. Note: Be sure to pick a region that supports Cloud Run."
  type        = string
}

variable "app_name" {
  description = "Name of the app."
  type        = string
  default     = "votes-app"
}

variable "branch_name" {
    description = "Example branch name used to trigger builds."
    default = "master"
}

variable "api_service_name" {
  description = "The name of the votes API service to deploy."
  type        = string
  default     = "votes-api"
}

variable "api_repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "votes-api"
}

variable "votes_service_name" {
  description = "The name of the votes app service to deploy."
  type        = string
  default     = "votes-app"
}

variable "votes_repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "votes-app"
}

variable "upvote_service_name" {
  description = "The name of the vote app service to deploy."
  type        = string
  default     = "upvote-app"
}

variable "upvote_repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "upvote-app"
}

variable "votes_function_service_name" {
  description = "The name of the votes function service to deploy."
  type        = string
  default     = "votes"
}

variable "votes_function_repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "votes-function"
}

variable "upvote_function_service_name" {
  description = "The name of the vote function service to deploy."
  type        = string
  default     = "upvote"
}

variable "upvote_function_repository_name" {
  description = "Name of the Google Cloud Source Repository to create."
  type        = string
  default     = "upvote-function"
}
