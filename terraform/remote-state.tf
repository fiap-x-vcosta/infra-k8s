data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = "fiap-x-vcosta-tfstate"
    prefix = "infra-bootstrap"
  }
}
