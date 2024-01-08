variable "instance_project" {
  type        = string
  default     = "<instance_project>"
}

variable "instance_name" {
  type        = string
  default     = "http-status"
}

variable "instance_zone" {
  type        = string
  default     = "us-central1-a"
}

resource "google_vpc" "vpc" {
  name     = "http-status-vpc"
  project  = var.instance_project
}

resource "google_compute_instance" "http-status" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network    = google_vpc.vpc.network
  subnetwork = google_vpc.vpc.subnet
}

resource "google_compute_instance" "test-instance" {
  name         = "test-instance"
  machine_type = "e2-micro"
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network    = google_vpc.vpc.network
  subnetwork = google_vpc.vpc.subnet
}