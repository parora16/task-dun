##### VPC

module "vpc" {
  source                                 = "../modules/vpc"
  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id
  description                            = var.description
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  mtu                                    = var.mtu
}

##### subnets

module "subnets" {
  source           = "../modules/subnet"
  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

##### VM instance 

resource "google_service_account" "dh" {
  project      =  var.project_id
  account_id   = "dh-serviceaccount"
  display_name = "DH Service Account"
}

resource "google_compute_instance" "dh-datapipeline" {
  name         = "dh-datapipeline"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  project      =  var.project_id

  tags = ["dh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network            = module.vpc.network_name
    subnetwork         = "dunnhumby-subnet"
    subnetwork_project = var.project_id
  }

  metadata = {
    dh = "datapipeline"
  }

  metadata_startup_script = ""

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.dh.email
    scopes = ["cloud-platform"]
  }
}

##### GCP Bucket


resource "google_storage_bucket" "buckset-dun" {
  name          = "dunnhumby_prashant_arora"
  location      = "US"
  force_destroy = true
  project       = var.project_id

  uniform_bucket_level_access = true
}

data "google_iam_policy" "objectadmin" {
  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "user:dh-serviceaccount@terra-testjamess.iam.gserviceaccount.com",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket = google_storage_bucket.default.name
  policy_data = data.google_iam_policy.objectadmin.policy_data
}