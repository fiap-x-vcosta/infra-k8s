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
