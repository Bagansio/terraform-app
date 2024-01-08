provider "google" {
  project = var.project_id
  region  = var.region
}

#Enable required APIs

resource "google_project_service" "enable_cloud_resource_manager_api" {
  project = var.project_id
  service                    = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "eventarc_api" {
  project   = var.project_id
  service = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_engine" {
    project = var.project_id
    service = "compute.googleapis.com"

    disable_on_destroy = false
}

resource "google_project_service" "cloud_functions" {
    project = var.project_id
    service = "cloudfunctions.googleapis.com"

    disable_on_destroy = false
}

resource "google_project_service" "vpc_access" {
    project = var.project_id
    service = "vpcaccess.googleapis.com"

    disable_on_destroy = false
}

resource "google_project_service" "iam" {
    project = var.project_id
    service = "iam.googleapis.com"

    disable_on_destroy = false
}

#create a service account
resource "google_service_account" "cf-sa" {
    account_id = "cf-ce-sa"
    display_name = "Service Account to CF manage CE"
}

# grant the SA user role
resource "google_project_iam_member" "cf-sa-user-role" {
  project = var.project_id

  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.cf-sa.email}"
}

# grant the Compute Instance Admin (beta) role
resource "google_project_iam_member" "cf-sa-compute-instance-admin-role" {
  project = var.project_id

  role = "roles/compute.instanceAdmin"
  member = "serviceAccount:${google_service_account.cf-sa.email}"
}

# grant the CF Service Agent role
resource "google_project_iam_member" "cf-sa-service-agent-role" {
  project = var.project_id

  role = "roles/cloudfunctions.serviceAgent"
  member = "serviceAccount:${google_service_account.cf-sa.email}"
}

#create a network
resource "google_compute_network" "service-vpc" {
  name     = "service-vpc"
  auto_create_subnetworks = false
}


#create a subnetwork
resource "google_compute_subnetwork" "service-subnet" {
  name                = "service-subnet"
  ip_cidr_range       = "10.0.1.0/24"
  region              = var.region
  network             = google_compute_network.service-vpc.name
}

resource "google_compute_instance" "http-status" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.service-subnet.name
  }

}

resource "google_compute_instance" "test-instance2" {
  name         = "test-instance2"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.service-subnet.name
  }
}

# create a cloud storage bucket for cloud function source code
resource "google_storage_bucket" "bucket" {
    name = "cf-function-source-bucket"
    location = var.region
}

resource "null_resource" "zip_folder" {
    provisioner "local-exec" {
      command = "zip -r cf.zip CF-manage-CE"
    }
}

# upload local folder to Cloud Storage bucket
resource "google_storage_bucket_object" "function_source" {
  name = "ce-manage-cf.zip"
  bucket = google_storage_bucket.bucket.name 
  source = "./cf.zip"

  depends_on = [ null_resource.zip_folder ]
}

resource "google_cloudfunctions2_function" "cf_manage_ce" {
    name = "CF-manage-CE"
    location = var.region
    
    build_config {
      runtime = "python312"
        entry_point = "instance_on_off"
        
        source {

            storage_source {
              bucket = google_storage_bucket.bucket.name
              object = google_storage_bucket_object.function_source.name
            }
        }
    }
    
    service_config {
      service_account_email = google_service_account.cf-sa.email
      available_memory = "256M"
      timeout_seconds = 60

      environment_variables = {
        instance_project = var.project_id
        instance_name = var.instance_name
        instance_zone = var.zone
      }
    }
}


output "function_uri" {
    value = google_cloudfunctions2_function.cf_manage_ce.service_config[0].uri
}