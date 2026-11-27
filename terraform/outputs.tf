output "cluster_name" {
  description = "Nome do cluster, usado pelo deploy dos serviços."
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "Região do cluster regional."
  value       = google_container_cluster.main.location
}

output "k8s_namespace" {
  description = "Namespace do Gateway e das service accounts Kubernetes."
  value       = var.k8s_namespace
}

output "runtime_workload_identity_members" {
  description = "Membros WI KSA→GSA (namespace/ksa). A chave é o account id (= nome do repositório)."
  value = {
    for id, email in data.terraform_remote_state.bootstrap.outputs.runtime_service_account_emails :
    id => "${var.project_id}.svc.id.goog[${var.k8s_namespace}/${id}]"
  }
}

output "gke_gateway_name" {
  description = "Nome do Gateway do GKE. HTTPRoute de serviço referencia este nome no listener https."
  value       = var.gke_gateway_name
}

output "api_static_ip" {
  description = "IP global do Gateway do GKE (A de api.<domínio>)."
  value       = google_compute_global_address.api.address
}

output "api_static_ip_name" {
  description = "Nome do IP global do Gateway do GKE."
  value       = google_compute_global_address.api.name
}

output "api_ssl_certificate_name" {
  description = "Certificado gerenciado anexado ao listener HTTPS do Gateway do GKE."
  value       = google_compute_managed_ssl_certificate.api.name
}

output "api_hostname" {
  description = "Hostname público da API (A → api_static_ip)."
  value       = local.api_hostname
}

output "public_path_prefix" {
  description = "Único path prefix público. HTTPRoute do bff usa este valor."
  value       = var.public_path_prefix
}
