# Laboratório: renovação automática de certificados, ao vivo

> Disciplina **Segurança de Sistemas** · Bloco 2 (a conexão web) · Atividade prática sobre certificados de vida curta

Neste laboratório você vai colocar no ar o **PortalAgenda** da Cais Azul, empresa fictícia de logística portuária usada nas aulas, com o servidor web **Caddy**. O Caddy tem uma **autoridade certificadora (AC) interna** e emite o certificado do próprio site. Esse certificado vai valer só **10 minutos** — e você vai ver o Caddy trocá-lo sozinho quando 2/3 da validade tiverem passado, sem ninguém lembrar e sem o site sair do ar.

Tudo roda no **GitHub Codespaces**, uma máquina Linux na nuvem acessada pelo navegador: **não é preciso instalar nada nem ter acesso de administrador** no computador do laboratório.

---

## O que você vai aprender

- Explicar por que os certificados públicos estão ficando cada vez mais curtos.
- Aplicar a **regra dos 2/3**: quando renovar e quanta folga sobra se a renovação falhar.
- Reconhecer a estrutura de uma **AC interna**: raiz longa, intermediária e certificados de site curtos.
- Observar uma **renovação automática** acontecendo, sem queda do serviço.
- Distinguir o que este laboratório mostra do protocolo **ACME** completo usado na internet.
- Conferir o cabeçalho **HSTS** numa resposta HTTPS.

## Como começar

1. **Crie a sua cópia** deste repositório: botão **Use this template → Create a new repository** (ou aceite o convite do GitHub Classroom enviado pelo professor).
2. Na sua cópia, clique em **Code → Codespaces → Create codespace on main**.
3. Quando o ambiente abrir, siga os documentos **nesta ordem**:

| # | Documento | Tempo |
|---|---|---|
| 1 | [Revisão teórica](docs/01-revisao-teorica.md) | ~15 min |
| 2 | [Roteiro passo a passo](docs/02-roteiro.md) | ~45 min |
| 3 | [Entrega: perguntas](ENTREGA.md) | durante o roteiro |
| + | [Desafios extras](docs/03-desafios.md) | opcional |

## Estrutura do repositório

```text
.
├── README.md                  ← você está aqui
├── ENTREGA.md                 ← perguntas a responder (entra no commit)
├── Caddyfile                  ← configuração do servidor, comentada linha a linha
├── observar.sh                ← mostra o certificado servido e marca cada troca
├── docs/
│   ├── 01-revisao-teorica.md  ← leia antes de começar
│   ├── 02-roteiro.md          ← as etapas do laboratório
│   └── 03-desafios.md         ← para quem terminar antes
├── evidencias/                ← saídas gravadas durante o roteiro (entram no commit)
├── scripts/
│   └── verificar.sh           ← confere a sua entrega
├── .devcontainer/             ← prepara o Codespace e instala o Caddy
└── .github/workflows/         ← verificação automática a cada push
```

## Entrega e verificação automática

- Ao final, você faz o commit do `ENTREGA.md` respondido e da pasta `evidencias/`, com a saída do certificado e o registro da renovação.
- A cada `git push`, o GitHub Actions roda `scripts/verificar.sh`: ele confere as evidências (certificado de cerca de 10 minutos emitido pela AC do laboratório e pelo menos uma troca registrada), o `Caddyfile`, as respostas e se nenhuma chave privada foi enviada ao Git.
- Você pode rodar a mesma verificação antes do commit: `bash scripts/verificar.sh`.

## Cuidados

- **Cota do Codespaces:** contas pessoais gratuitas têm uma cota mensal de uso. Ao terminar, **pare o Codespace** (Code → Codespaces → ⋯ → Stop codespace).
- **Somente laboratório:** a AC do Caddy existe só dentro do seu Codespace. Nunca instale a raiz de uma AC de laboratório no seu navegador do dia a dia.
- **Segredos:** as chaves privadas do Caddy ficam em `~/.local/share/caddy`, fora do repositório. Não as copie para cá.

---

<sub>Para o professor: marque este repositório como <i>Template repository</i> em <b>Settings → General</b> para que os alunos criem as próprias cópias.</sub>
