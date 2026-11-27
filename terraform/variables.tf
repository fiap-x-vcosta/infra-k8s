variable "project_id" {
  type        = string
  description = "GCP project ID da demo."
  default     = "fiap-x-vcosta"
}

variable "region" {
  type        = string
  description = "Região primária da demo (fechada: us-central1)."
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster GKE Autopilot (org var GCP_GKE_CLUSTER_NAME)."
  default     = "fiap-x-gke"
}

variable "release_channel" {
  type        = string
  description = "Release channel do cluster."
  default     = "REGULAR"
}

variable "k8s_namespace" {
  type        = string
  description = "Namespace compartilhado do Gateway e das service accounts Kubernetes."
  default     = "fiap-x"
}
