provider "google" {
 project = "walter-web-test"
 region = "us-central1"
 zone = "us-central1-c"
}

# Create Database
resource "google_sql_database_instance" "master" {
    name = var.name
    region = var.db_region
    database_version = var.database_version

    settings {
        activation_policy = var.activation_policy
        crash_safe_replication = true
        tier = var.tier
        disk_size = var.disk_size
        replication_type = var.replication_type
        availability_type = "ZONAL"

        backup_configuration {
            enabled = true
            start_time = "21:00"
        }
    }

    replica_configuration {
        ca_certificate = "walter-root"
    }
}

# Create User
resource "google_sql_user" "users" {
    count = 1
    name = var.user_name
    host = var.user_host
    password = var.user_password
    instance = google_sql_database_instance.master.name
}


# Create VM
resource "google_compute_instance" "CMS" {
  name         = "CMS Server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  project       = "WEB Migration"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}