terraform {
  backend "gcs" {
    bucket = "fiap-x-vcosta-tfstate"
    prefix = "infra-k8s"
  }
}
