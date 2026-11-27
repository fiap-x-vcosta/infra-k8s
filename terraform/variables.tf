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

variable "gke_gateway_name" {
  type        = string
  description = "Nome do Gateway do GKE no namespace compartilhado."
  default     = "public"
}

variable "api_static_ip_name" {
  type        = string
  description = "Nome do IP global do Gateway do GKE (hostname api.<domínio>)."
  default     = "fiap-x-api"
}

variable "api_ssl_certificate_name" {
  type        = string
  description = "Nome do certificado gerenciado do hostname api.<domínio>."
  default     = "fiap-x-api-cert"
}

variable "public_path_prefix" {
  type        = string
  description = "Único path prefix público no Gateway (HTTPRoute do bff)."
  default     = "/bff"
}
