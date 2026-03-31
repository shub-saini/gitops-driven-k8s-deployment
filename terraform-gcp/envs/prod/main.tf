resource "random_id" "project" {
  byte_length = 2
}


resource "google_project" "project" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.project.dec}"
  billing_account = var.billing_account_id
  org_id          = var.org_id

  deletion_policy = "DELETE"
}

locals {
  project_id = google_project.project.project_id
}

resource "google_project_service" "apis" {
  project = local.project_id

  for_each = toset(var.apis)
  service  = each.key

  disable_on_destroy = false
}

module "gcr" {
  source = "../../modules/gcr"

  location      = var.region
  project_id    = local.project_id
  repository_id = var.container_registry_repository_id

  depends_on = [google_project_service.apis, module.gke]
}

module "gke" {
  source = "../../modules/gke"

  name       = var.gke_name
  project_id = local.project_id
  zone       = var.zone

  network_self_link             = module.vpc.vpc_self_link
  subnetwork_self_link          = module.vpc.subnets["private-subnet-1"].self_link
  pods_secondary_range_name     = "gke-pods"
  services_secondary_range_name = "gke-services"

  master_ipv4_cidr_block  = "10.0.64.0/28"
  enable_private_cluster  = true
  enable_private_endpoint = false

  node_pools = [
    {
      name               = "default-pool"
      machine_type       = "e2-standard-4"
      min_node_count     = 1
      max_node_count     = 2
      initial_node_count = 1
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      spot               = false
    },
  ]

  enable_workload_identity = true
  enable_network_policy    = true
  deletion_protection      = false

  depends_on = [google_project.staging, google_project_service.apis]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.3.7"

  values = [
    <<-EOT
    server:
      extraArgs:
        - --insecure
    EOT
  ]
}

resource "google_secret_manager_secret" "db_connection_string" {
  project   = local.project_id
  secret_id = "db-connection-string"

  replication {
    auto {}
  }
  deletion_protection = false

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "jwt_secret" {
  project   = local.project_id
  secret_id = "jwt-secret"

  replication {
    auto {}
  }
  deletion_protection = false

  depends_on = [google_project_service.apis]
}
