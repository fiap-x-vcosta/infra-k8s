# ADR 002: Gateway do GKE como borda pública

**Data:** 27 de Novembro de 2026  
**Status:** Aceito  
**Autores:** Victor Costa

## 1. Contexto e Problema

A janela pública HTTP do produto é o `bff` (`consultas-service`). Front estático (`www` / apex) fica em outro stack. Precisamos de HTTPS nomeado até o cluster, com `plan` de PR possível com o cluster desligado, e custo baixo na janela.

**Problema:** como expor só o `bff` em `api.<domínio>` sem GCP API Gateway e sem segundo LB?

## 2. Decisão

- **Borda:** um Gateway do GKE, classe `gke-l7-global-external-managed`, namespace `fiap-x`, nome `public`.
- **Hostname:** `api.vcosta-fiap.online`. IP global `fiap-x-api`. Certificado managed SSL `fiap-x-api-cert` via `networking.gke.io/pre-shared-certs`.
- **Path público:** somente **`/bff`**. O `HTTPRoute` correspondente mora no repositório `consultas-service` (listener `https` do Gateway `public`).
- **Demais serviços:** ClusterIP / DNS interno do cluster. `/system` não entra na borda pública.
- **Objeto Gateway:** manifesto [`terraform/gke-gateway.yaml.tpl`](../../terraform/gke-gateway.yaml.tpl), aplicado com `kubectl` no `tf-apply`. Fora do state Terraform.
- **Listeners:** `http` redireciona para HTTPS; `https` aceita `HTTPRoute` do mesmo namespace.
- **Sem** GCP API Gateway e **sem** HTTPS LB no apex neste stack. Apex/`www` são responsabilidade do front.

## 3. Justificativa

- Um único LB global na janela atende o budget acadêmico.
- O FE e smokes falam com `https://api.<domínio>/bff/...` (inclui Swagger do app).
- Manifesto no workflow mantém `plan` de PR sem cluster ligado.
- Certificado managed do Compute encaixa na classe global do Gateway.

## 4. Alternativas consideradas

- **GCP API Gateway + 2º LB no apex:** padrão da org exemplo; custo e peças a mais sem ganho com um único serviço público.
- **Provider Kubernetes no Terraform:** `plan` quebra com cluster desligado.
- **Vários paths públicos** (`/processamento`, …): rejeitado — janela pública = só `bff`.

## 5. Consequências

- Contrato estável: namespace `fiap-x`, Gateway `public`, listener `https`, path `/bff`.
- Certificado fica Active depois que o DNS aponta e o Gateway anexa o cert.
- Destroy deve limpar Gateway/`HTTPRoute` e esperar a forwarding rule do IP `api` antes de destruir o cluster.
