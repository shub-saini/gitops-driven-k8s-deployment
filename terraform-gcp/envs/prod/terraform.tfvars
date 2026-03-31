region             = "us-central1"
zone               = "us-central1-f"
environment        = "prod"
project_name       = "prod"
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

container_registry_repository_id = "prod-apis"
vpc_name                         = "prod-vpc"
db_name                          = "prod-db"

gke_name = "prod-gke"