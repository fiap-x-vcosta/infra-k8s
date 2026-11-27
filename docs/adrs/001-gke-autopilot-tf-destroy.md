# ADR 001: GKE Autopilot e ciclo `tf-destroy`

**Data:** 27 de Novembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

Os serviços .NET rodam na GCP com escala horizontal, na mesma VPC do Cloud SQL, com Workload Identity. O cluster é o maior custo da demo: deve ligar só na janela e sumir no destroy.

**Problema:** qual modo de GKE usar, e como o destroy evita órfãos de cobrança?

## 2. Decisão

- **Cluster:** GKE **Autopilot** regional `fiap-x-gke` em `us-central1`, VPC-native (rede do `infra-bootstrap`), nós privados.
- **Egress:** **Cloud NAT** na subnet da demo (neste stack). Não mora no `infra-bootstrap` (custo por hora da janela).
- **Control plane:** **DNS-only** (acesso por DNS + IAM; sem endpoint IP).
- **Escopo deste repo:** cluster + NAT + bindings de Workload Identity + Gateway do GKE + DNS/cert de `api.<domínio>`. Manifests de cada workload ficam no repositório do serviço.
- **Ciclo:** `tf-apply` / `tf-destroy` **manuais**. Antes do destroy, o caller remove Gateway/`HTTPRoute`/LBs órfãos e espera a forwarding rule do IP `api` sumir.

## 3. Justificativa

- Autopilot reduz operação de nós e cobra perto do uso dos pods.
- DNS-only evita bastion e allowlist de IP para CI.
- Destroy sem carve-outs: state = nuvem; recriar no próximo apply é aceitável.

## 4. Alternativas consideradas

- **GKE Standard:** pior custo ocioso na demo curta.
- **Cluster permanente no bootstrap:** taxa de management + risco de pod esquecido.
- **Kind / self-hosted:** fora do caminho de entrega na nuvem.

## 5. Consequências

- Merge em `main` nunca liga o cluster.
- Workload Identity de runtime mora aqui (pool `svc.id.goog` só com cluster vivo).
- Esquecer o destroy deixa Autopilot e o LB do Gateway sangrando — `demo-down` obrigatório.
