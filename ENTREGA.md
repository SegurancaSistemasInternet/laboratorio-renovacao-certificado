# Entrega — Laboratório "Renovação automática de certificados"

**Nome(s):** _(responda aqui)_
**Turma:** _(responda aqui)_

> Responda abaixo de cada pergunta, substituindo o texto *(responda aqui)*. Quando terminar, rode `bash scripts/verificar.sh` e siga a **etapa 6** do roteiro para fazer o commit.

---

## Parte A — A AC interna e o certificado de vida curta (etapas 2 e 3)

**1.** A raiz do Caddy vale cerca de 10 anos, a intermediária 7 dias e o certificado do site 10 minutos. Por que validades tão diferentes para cada nível da cadeia?

_(responda aqui)_

**2.** Na etapa 3, o `curl` recusou a conexão em 3.1 e aceitou em 3.2. O que mudou? O que uma empresa faz para que **todos** os seus computadores confiem na própria AC interna — e qual o risco dessa decisão?

_(responda aqui)_

## Parte B — A renovação (etapas 4 e 5)

**3.** Pela regra dos 2/3, complete a tabela:

| Validade do certificado | Renovação após | Folga para agir se falhar |
|---|---|---|
| 10 minutos (este laboratório) | ≈ 6 min 40 s | ≈ 3 min 20 s |
| 12 horas (padrão do Caddy) | _(responda aqui)_ | |
| 47 dias (limite público a partir de 2029) | _(responda aqui)_ | |
| 90 dias | _(responda aqui)_ | |
| 200 dias (limite público em 2026) | _(responda aqui)_ | |

**4.** No experimento 5.1, o que o Caddy fez ao ser religado depois da marca de 2/3? E se ele tivesse ficado desligado até **depois** do vencimento: o que um navegador veria enquanto o servidor estivesse fora — e assim que ele voltasse?

_(responda aqui)_

**5.** No experimento 5.2, a renovação passou a acontecer na metade da validade. Quais as vantagens e as desvantagens de renovar mais cedo?

_(responda aqui)_

## Parte C — Fechamento

**6.** Compare este laboratório com o vídeo "Em movimento: renovação automática com ACME" da aula. O que aconteceu do mesmo jeito? Qual etapa do ACME **não** aconteceu aqui, e por quê? O que seria preciso para o PortalAgenda real, em `agenda.caisazul.com.br`, ter certificados **públicos** renovados da mesma forma?

_(responda aqui)_

---

## Evidências (gravadas durante o roteiro)

- [ ] `evidencias/certificado.txt` — etapa 3.4
- [ ] `evidencias/renovacao.txt` — etapas 4 e 5, com pelo menos um `<<< CERTIFICADO NOVO`
