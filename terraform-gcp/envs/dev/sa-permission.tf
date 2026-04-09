resource "google_artifact_registry_repository_iam_member" "gke_reader_for_gcr" {
  for_each = module.gke.node_pool_service_accounts

  project    = local.project_id
  location   = var.region
  repository = module.gcr.repository_name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${each.value}"

  depends_on = [google_project_service.apis, module.gke, module.gcr]
}

resource "google_service_account" "gke_external_secrets_sa" {
  account_id   = "gke-external-secrets-sa"
  display_name = "Service account for External Secrets Operator"
  project      = local.project_id
}

resource "google_project_iam_member" "external_secrets_sa_secret_access_permission" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.gke_external_secrets_sa.email}"
}

resource "google_project_iam_member" "cloudsql_client_permission" {
  project = local.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.gke_external_secrets_sa.email}"
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gke_external_secrets_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[external-secrets-system/external-secrets-operator-sa]" // [namespace/k8s service account with annotation]

  depends_on = [google_project_service.apis, module.gke]
}

resource "google_service_account_iam_member" "backend_workload_identity_binding" {
  service_account_id = google_service_account.gke_external_secrets_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[default/db-client-sa]"
}
