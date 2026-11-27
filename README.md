# infra-k8s

Terraform do **cluster GKE Autopilot**, **Gateway of GKE** e bindings de Workload Identity do FIAP X ([`fiap-x-vcosta`](https://github.com/fiap-x-vcosta)).

Canon de produto: [`docs`](https://github.com/fiap-x-vcosta/docs). Rede, zona DNS e SAs de runtime: [`infra-bootstrap`](https://github.com/fiap-x-vcosta/infra-bootstrap).

## Escopo

- Cluster GKE Autopilot `fiap-x-gke` (ciclo de demo)
- Namespace Kubernetes `fiap-x`
- Gateway of GKE em `api.vcosta-fiap.online`
- Única rota pública: `/bff` → `consultas-service` (`bff`); demais serviços só internos ao cluster
- Sem GCP API Gateway
- Workload Identity (KSA → GSA de runtime) enquanto o cluster existir
- Records DNS da janela pública na zona gerenciada pelo bootstrap
- Região `us-central1`, projeto `fiap-x-vcosta`
- State remoto em GCS (bucket gerenciado pelo [`infra-bootstrap`](https://github.com/fiap-x-vcosta/infra-bootstrap); `tf-destroy` não o apaga)

Manifests de Deployment/Service de cada microsserviço moram no repositório do serviço (`k8s/`). Este stack sobe o cluster, a entrada e o binding de identidade.

Root module: [`terraform/`](terraform/). Pin Terraform: **1.16.1** (alinhado a [`actions`](https://github.com/fiap-x-vcosta/actions)).

## Entrada pública

| Item | Valor |
|------|--------|
| Host | `api.vcosta-fiap.online` |
| Gateway | Gateway of GKE |
| Path público | `/bff` → `consultas-service` |
| Demais serviços | Internos (sem exposição no Gateway) |

Não há GCP API Gateway neste projeto.

## State (GCS)

| Item | Valor |
|------|--------|
| Bucket | `fiap-x-vcosta-tfstate` |
| Prefix deste repo | `infra-k8s` |

Rede, Artifact Registry, e-mails das SAs de runtime e zona DNS vêm do `terraform_remote_state` do [`infra-bootstrap`](https://github.com/fiap-x-vcosta/infra-bootstrap).

## CI vs CD

| Tipo | Quando | Automático? |
|------|--------|-------------|
| **CI** `fmt` + `validate` | PR / push | Sim |
| **CI** `plan` (OIDC) | PR | Sim |
| **`tf-apply` / `tf-destroy`** | Janela da demo / sob demanda | Só manual (`workflow_dispatch`) |

Merge em `main` **nunca** sobe o cluster. O gatilho de apply/destroy é **manual** (`workflow_dispatch`). Passos extras (Gateway pós-apply, cleanup pré-destroy) ficam em **jobs do caller**, cobertos pelo mesmo concurrency — ver [`actions`](https://github.com/fiap-x-vcosta/actions).

Os callers usam [`fiap-x-vcosta/actions`](https://github.com/fiap-x-vcosta/actions) e autenticam com as org vars `GCP_WORKLOAD_IDENTITY_PROVIDER` e `GCP_SERVICE_ACCOUNT_EMAIL`.

## Comandos locais

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

Plan/apply local exigem ADC (`gcloud auth application-default login`) e backend GCS (`terraform init` sem `-backend=false`).

## Roles da SA `github-actions` (least-privilege)

A service account, o OIDC e as roles são código no [`infra-bootstrap`](https://github.com/fiap-x-vcosta/infra-bootstrap). Deste conjunto, este stack usa (entre outras):

- roles de GKE / container para criar e destruir o cluster Autopilot
- `roles/dns.admin` — records da janela na zona `vcosta-fiap.online`
- role customizada de binding KSA→GSA (Workload Identity de runtime)
- no bucket de state: `roles/storage.objectAdmin`

Este repositório já está em `ci_repositories` do bootstrap (WIF por repositório).

## Ordem na demo

O `infra-bootstrap` já está aplicado e não entra neste ciclo. O destroy daqui não toca no bucket de state nem na zona DNS.

Subida:

1. Este repo → **tf-apply** (cluster + Gateway + WI), em paralelo com [`infra-events`](https://github.com/fiap-x-vcosta/infra-events) → **tf-apply**
2. **tf-apply** de cada serviço (Cloud SQL + subscription/dead-letter + IAM)
3. Deploy dos serviços

Descida:

1. **tf-destroy** de cada serviço
2. [`infra-events`](https://github.com/fiap-x-vcosta/infra-events) → **tf-destroy**
3. Este repo → **tf-destroy**

## Agentes

Ver [AGENTS.md](AGENTS.md).
