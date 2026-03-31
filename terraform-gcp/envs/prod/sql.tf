module "private_service_access" {
  source  = "terraform-google-modules/sql-db/google//modules/private_service_access"
  version = "~> 28.0"

  project_id      = local.project_id
  vpc_network     = module.vpc.vpc_name
  deletion_policy = "ABANDON" # prevents terraform destroy from hanging

  depends_on = [module.vpc]
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

module "pg" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 28.0"

  name                 = var.db_name
  random_instance_name = true
  project_id           = local.project_id
  database_version     = "POSTGRES_18"
  region               = var.region

  tier              = "db-perf-optimized-N-2"
  zone              = "${var.region}-b"
  availability_type = "ZONAL"

  maintenance_window_day          = 7
  maintenance_window_hour         = 3
  maintenance_window_update_track = "stable"

  deletion_protection = false # set true before prod

  database_flags = []

  user_labels = {
    env = "sandbox"
  }

  # Networking — public IP + private IP via PSA
  ip_configuration = {
    ipv4_enabled        = true # public IP on
    private_network     = module.vpc.vpc_self_link
    allocated_ip_range  = null
    ssl_mode            = "ENCRYPTED_ONLY"
    authorized_networks = []
  }

  # Backups OFF — sandbox
  # Note: enabled=false still needs start_time set (GCP provider requirement)
  backup_configuration = {
    enabled                        = false
    start_time                     = "03:00"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = null
    retention_unit                 = null
  }

  read_replicas = []

  user_name            = "postgres"
  user_password        = random_password.db_password.result
  user_deletion_policy = "ABANDON"

  depends_on = [module.private_service_access]
}

resource "google_secret_manager_secret_version" "db_connection_string" {
  secret      = google_secret_manager_secret.db_connection_string.name
  secret_data = "postgresql://postgres:${random_password.db_password.result}@127.0.0.1:5432/postgres"
}