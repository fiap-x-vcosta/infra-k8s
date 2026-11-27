# Guia para agentes — `infra-k8s` (FIAP X)

Terraform do **GKE Autopilot**, **Gateway of GKE** e Workload Identity do ciclo de demo do FIAP X. Org [`fiap-x-vcosta`](https://github.com/fiap-x-vcosta).

Canon de produto: [`docs`](https://github.com/fiap-x-vcosta/docs). Rede / zona DNS / SAs: [`infra-bootstrap`](https://github.com/fiap-x-vcosta/infra-bootstrap).

## Antes de mudar código

1. Ler o [README](README.md) e as decisões de entrada (só `/bff` público; sem GCP API Gateway)
2. Espelhar o layout flat em `terraform/`; não inventar layout paralelo
3. Não rodar `apply`/`destroy` sem confirmação explícita do usuário
4. **Git:** nunca commit/push direto em `main` — branch → PR → merge humano (ver [`.cursor/rules/git-workflow.mdc`](.cursor/rules/git-workflow.mdc))
5. Naming: proibida a string que combina o produto com “videos” em camel/kebab/snake

## Responsabilidade

| Peça | Papel |
|------|--------|
| Terraform | Cluster Autopilot `fiap-x-gke`, namespace `fiap-x`, Gateway of GKE em `api.vcosta-fiap.online`, WI KSA→GSA, records DNS da janela |
| Apply/destroy | Manuais via callers `tf-apply` / `tf-destroy` (`workflow_dispatch`); extras de Gateway/cleanup no caller |
| Fora de escopo | Manifests dos serviços, Cloud SQL, tópicos Pub/Sub, buckets de mídia, Memorystore, código de aplicação, GCP API Gateway |

## Regras canônicas (resumo)

- Só path público `/bff` (`consultas-service`); demais serviços internos
- Sem GCP API Gateway — entrada = Gateway of GKE
- Binding KSA → GSA mora aqui (pool `svc.id.goog` só com cluster vivo)
- CI barato (`fmt` / `validate` / `plan`); CD caro só manual
- Sem secrets no Git; README autocontido na org

## Comandos

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
# plan/apply reais: só com backend GCS e confirmação humana (workflow ou ADC)
```
