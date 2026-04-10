region             = "us-central1"
zone               = "us-central1-f"
environment        = "dev"
project_name       = "development"
org_id             = "709498044594"
billing_account_id = "01B75F-9B21A3-655BD2"
apis = [
  "compute.googleapis.com",
  "container.googleapis.com",
  "logging.googleapis.com",
  "secretmanager.googleapis.com",
  "storage.googleapis.com",
  "artifactregistry.googleapis.com",
  "sqladmin.googleapis.com",
  "servicenetworking.googleapis.com",
  "iam.googleapis.com",
  "iamcredentials.googleapis.com",
  "sts.googleapis.com",
  "cloudresourcemanager.googleapis.com"
]

container_registry_repository_id = "dev-apis"
vpc_name                         = "dev-vpc"
db_name                          = "dev-db"

gke_name = "dev-gke"