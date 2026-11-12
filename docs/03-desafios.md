# 3. Desafios extras

Para quem terminou o roteiro. **Não fazem parte da entrega.** Rode os comandos na raiz do repositório, com o Caddy no ar, e defina antes a variável:

```bash
CA=~/.local/share/caddy/pki/authorities/local
```

---

## Desafio 1 — Conferir a cadeia do Caddy com o OpenSSL

Se você fez o laboratório **AC da turma**, já sabe verificar uma cadeia. Faça o mesmo com a AC do Caddy:

```bash
openssl s_client -connect 127.0.0.1:8443 -servername agenda.caisazul.test </dev/null 2>/dev/null \
  | openssl x509 > folha.crt
openssl verify -CAfile $CA/root.crt -untrusted $CA/intermediate.crt folha.crt
openssl x509 -in folha.crt -noout -ext basicConstraints,keyUsage,extendedKeyUsage,subjectAltName
```

**Pergunta:** as extensões do certificado emitido pelo Caddy são parecidas com as do `config/site.ext` do laboratório AC da turma? O que muda?

---

## Desafio 2 — Um vigia de validade

O OpenSSL responde se um certificado vence nos próximos N segundos:

```bash
openssl x509 -in folha.crt -noout -checkend 200
```

👀 `Certificate will expire` ou `Certificate will not expire`.

Escreva um script `vigia.sh` que, a cada 20 segundos, pegue o certificado servido e mostre **ALERTA** quando restar menos de 1/3 da validade e o certificado ainda não tiver sido trocado. Dica: aproveite o cálculo de datas do `observar.sh`.

**Pergunta:** num servidor de verdade, para quem esse alerta deveria ir, e por qual canal?

---

## Desafio 3 — HSTS mais completo

1. No `Caddyfile`, troque a linha do cabeçalho por:

   ```text
   header Strict-Transport-Security "max-age=31536000; includeSubDomains"
   ```

2. Recarregue (`caddy reload --config Caddyfile`) e confira com `curl -sI --cacert $CA/root.crt --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/`.
3. Desfaça a alteração depois (`git checkout Caddyfile`).

**Pergunta:** o que `includeSubDomains` muda? Que problema ele poderia causar para a Cais Azul se algum subdomínio interno ainda não tiver HTTPS?

---

## Desafio 4 — Vida ainda mais curta

Mude `lifetime` para `2m` e `renew_interval` para `10s`, recarregue e observe com `bash observar.sh 5`. Depois volte aos valores originais (`git checkout Caddyfile` e recarregue).

**Pergunta:** se certificados curtos são mais seguros, por que não usar certificados de 2 minutos em produção? Pense na carga sobre a AC, no que acontece quando a AC fica fora do ar por alguns minutos e em relógios desacertados.

---

## Desafio 5 — E se a raiz mudar?

Simule a perda da AC interna:

```bash
cp $CA/root.crt raiz-antiga.crt           # guarde a raiz atual
# Pare o Caddy (Ctrl + C no terminal 1) e apague a AC e os certificados:
rm -rf ~/.local/share/caddy/pki ~/.local/share/caddy/certificates
# Suba o Caddy de novo (comando da etapa 1). Depois, teste:
curl --cacert raiz-antiga.crt --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/
curl --cacert $CA/root.crt    --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/
```

👀 Com a raiz antiga, a conexão é recusada; com a nova, funciona.

**Pergunta:** na Cais Azul, a raiz interna está instalada em 800 computadores. O que significaria perder a chave dessa raiz — ou ela vazar? Por que a raiz vive 10 anos e fica guardada com tanto cuidado, enquanto os certificados de site podem ser descartáveis?
