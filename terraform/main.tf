provider "google" {
  project = var.my_gcp_project
  region  = var.region
}

data "google_project" "project" {
}

resource "google_project_service" "composer_api" {
  provider           = google
  project            = var.my_gcp_project
  service            = "composer.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  provider           = google
  project            = var.my_gcp_project
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_build_api" {
  provider           = google
  project            = var.my_gcp_project
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}


resource "google_service_account" "custom_service_account" {
  provider     = google
  account_id   = "custom-service-account"
  display_name = "Terraform Custom Service Account"
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google
  project  = var.my_gcp_project
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role = "roles/composer.worker"
}

resource "google_service_account_iam_member" "custom_service_account" {
  provider           = google
  service_account_id = google_service_account.custom_service_account.name
  role               = "roles/composer.ServiceAgentV2Ext"
  member             = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"

  depends_on = [google_project_service.composer_api]

}

resource "google_composer_environment" "example_environment" {
  // ---- Challenge ---- // 
  // Create a cloud composer 2 instance following the documenation below: 
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/composer_environment#with-gke-and-compute-resource-dependencies
    provider = google
      name = "gcp-environment"

      config {
        software_config {
          image_version = "composer-2.4.5-airflow-2.4.3"
        }

        node_config {
          service_account = google_service_account.custom_service_account.email
        }

      }
}

resource "google_compute_network" "test" {
  name                    = "composer-test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test" {
  name          = "composer-test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.test.id
}