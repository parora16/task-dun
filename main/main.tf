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


module "subnets" {
  source           = "../modules/subnet"
  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

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

  // Local SSD disk
 // scratch_disk {
//    interface = "SCSI"
 // }

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
