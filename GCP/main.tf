##################################################################################
# OpenTofu Configuration
#
# Specifies the required provider for Google Cloud and its version.
##################################################################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

##################################################################################
# Provider Configuration
#
# Configures the Google Cloud provider with the project and region.
##################################################################################

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

##################################################################################
# Input Variables
#
# Defines variables that the user must provide or can override.
##################################################################################

variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID to deploy resources into."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to deploy resources into."
  default     = "us-east1"
}

variable "node_count" {
  type        = string
  description = "Number of Nodes for this environment"
  default     = "1"
}

##################################################################################
# Resource: Google Compute Instance
#
# Provisions e2-standard-2 virtual machine with internet access.
##################################################################################

resource "google_compute_instance" "web_server" {
  count        = 1
  name         = "rss-iacm-instance-${count.index}"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-c"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // An empty access_config block assigns an ephemeral public IP.
    }
  }

  // Add network tags for firewall rules
  tags = ["http-server", "https-server", "ssh-server"]

  // Add metadata for potential startup scripts or SSH keys
  metadata = {
    "created-by" = "opentofu"
  }

  // Added so we can resize instance types
  allow_stopping_for_update = true
}

##################################################################################
# Outputs
#
# Displays useful information after the infrastructure is provisioned.
##################################################################################

output "instance_names" {
  description = "The names of the created compute instances."
  value       = google_compute_instance.web_server[*].name
}

output "instance_public_ips" {
  description = "The public IP addresses of the created instances."
  value       = google_compute_instance.web_server[*].network_interface[0].access_config[0].nat_ip
}

output "instance_private_ips" {
  description = "The private IP addresses of the created instances."
  value       = google_compute_instance.web_server[*].network_interface[0].network_ip
}
