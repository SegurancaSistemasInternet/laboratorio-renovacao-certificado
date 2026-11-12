# Laboratório: renovação automática de certificados, ao vivo

> Disciplina **Segurança de Sistemas** · Bloco 2 (a conexão web) · ⏱️ cerca de 50 minutos

Neste laboratório você vai colocar no ar o **PortalAgenda** da Cais Azul, empresa fictícia de logística portuária usada nas aulas, com o servidor web **Caddy**. O Caddy tem uma **autoridade certificadora (AC) interna** e emite o certificado do próprio site. Esse certificado vai valer só **10 minutos** — e você vai ver o Caddy trocá-lo sozinho quando 2/3 da validade tiverem passado, sem ninguém lembrar e sem o site sair do ar.

Tudo roda no **GitHub Codespaces**, uma máquina Linux na nuvem acessada pelo navegador: **não é preciso instalar nada nem ter acesso de administrador** no computador do laboratório. Você vai trabalhar numa **cópia deste repositório na sua própria conta do GitHub**, com um Codespace seu.

---

## Antes de tudo: o que você vai entregar

Você vai preencher um **documento Word** durante a atividade e enviá-lo na **tarefa do Teams**.

1. **Baixe o modelo agora:** [⬇️ Modelo-Entrega-Renovacao-Certificado.docx](https://github.com/SegurancaSistemasInternet/laboratorio-renovacao-certificado/raw/main/entrega/Modelo-Entrega-Renovacao-Certificado.docx)
2. Abra o arquivo no Word e deixe-o aberto ao lado do navegador.
3. Ao longo do roteiro, sempre que aparecer **📸 EVIDÊNCIA**, tire um print e cole no quadro correspondente do documento.
4. No fim, responda às **3 perguntas**, salve como `Entrega-Renovacao-SeuNome.docx` e envie na tarefa do Teams.

> 📷 **Como tirar print:** no Windows, **Windows + Shift + S**, selecione a área e cole no Word com **Ctrl + V**. No Mac, **Cmd + Ctrl + Shift + 4** e **Cmd + V**.

**Os símbolos deste roteiro**

| Símbolo | Significado |
|---|---|
| ✅ **CHECKPOINT** | Confira se está tudo certo antes de seguir. Se não estiver, veja [Problemas comuns](#problemas-comuns). |
| 📸 **EVIDÊNCIA** | Tire o print indicado e cole no documento de entrega. |
| ❓ **PERGUNTA** | Responda no documento de entrega. |

**Resumo da entrega**

| Item | Onde acontece |
|---|---|
| 📸 Evidência 1 — o servidor no ar | Etapa 1 |
| 📸 Evidência 2 — a AC interna do Caddy | Etapa 2 |
| 📸 Evidência 3 — acessando o site | Etapa 3 |
| 📸 Evidência 4 — o certificado de 10 minutos | Etapa 3 |
| ❓ Pergunta 1 | Etapa 3 |
| 📸 Evidência 5 — a renovação automática | Etapa 4 |
| ❓ Pergunta 2 | Etapa 4 |
| 📸 Evidência 6 — servidor desligado e religado | Etapa 5 |
| ❓ Pergunta 3 | Etapa 6 |

---

## Parte 1 — O essencial em 5 minutos

**O problema.** Todo **certificado digital** tem validade: depois da data `notAfter`, navegadores e programas o recusam. Renovar "na mão" depende de alguém lembrar, pedir, instalar e reiniciar o servidor no prazo — e, quando isso falha, o site sai do ar para todo mundo.

**Por que os certificados estão ficando mais curtos.** Se a chave privada de um site vaza, cancelar o certificado (**revogar**) funciona mal na prática: muitos clientes não consultam essa informação. Um certificado curto limita o estrago e obriga a automação. O CA/Browser Forum, que define as regras dos certificados públicos, aprovou em 2025 a redução gradual da validade máxima: **200 dias** a partir de março de 2026, **100 dias** em 2027 e **47 dias** em 2029.

**Renovação automática e a regra dos 2/3.** Um programa no servidor acompanha a validade e troca o certificado sozinho. A regra usada é **renovar quando restar 1/3 da validade** — ou seja, depois de usados **2/3**. O terço restante é a **folga** para tentar de novo e avisar alguém, caso a renovação falhe.

```text
Certificado de 10 minutos (este laboratório)
0 min                         6 min 40 s             10 min
|---------- uso normal (2/3) ----------|--- folga (1/3) ---|
emissão                     renovação começa          vencimento
```

**O ACME.** Na internet, a renovação automática usa o protocolo **ACME** (*Automatic Certificate Management Environment*): o cliente no servidor **pede** o certificado, recebe um **desafio**, **prova** que controla o domínio, envia o pedido com a chave pública (**CSR**), a **AC emite** e o cliente **instala**.

**AC interna.** É uma autoridade certificadora da própria organização, para sistemas internos. Seus certificados só são aceitos por computadores que tenham a **raiz** dela instalada como confiável. A AC interna do Caddy tem uma **raiz** (cerca de 10 anos), uma **intermediária** (7 dias) e emite os certificados dos sites (padrão de 12 horas; **10 minutos** neste laboratório).

**O que este laboratório simplifica.** Aqui o Caddy é **ao mesmo tempo a AC e o servidor**. O que você vai observar de verdade é o ciclo de vida: emissão, vida curta, renovação a 2/3 e troca sem queda do site.

**HSTS.** O cabeçalho `Strict-Transport-Security` faz o navegador usar **só HTTPS** naquele site pelo tempo indicado. Você vai conferi-lo na etapa 3.

**A configuração.** O servidor é configurado pelo arquivo [`Caddyfile`](Caddyfile), comentado linha a linha. Repare em três linhas: `lifetime 10m` (validade do certificado), `renewal_window_ratio 0.3333` (a regra dos 2/3) e `renew_interval 30s` (o Caddy confere a validade a cada 30 segundos).

---

## Parte 2 — Roteiro

**Como trabalhar**

- Os comandos rodam na **raiz do repositório**, a pasta em que o terminal do Codespace abre.
- Você vai usar **dois terminais**: o **terminal 1** mostra o diário (log) do servidor; o **terminal 2** é onde você digita os testes. Para abrir outro terminal, clique no **+** do painel do terminal.
- Para copiar um comando, use o botão de copiar que aparece no canto do bloco de código.
- A hora do Codespace é **UTC**: 3 horas à frente do horário de Brasília.

> ⏰ **O relógio começa na Etapa 1.** O primeiro certificado é emitido assim que o servidor sobe e é trocado cerca de 7 minutos depois. Faça as etapas 2 e 3 sem pausas longas. Se perder a primeira troca, não tem problema: outra acontece cerca de 7 minutos depois.

### Etapa 0 — Preparar o ambiente (5 min)

1. Confira se você já **baixou o modelo de entrega** e o deixou aberto no Word ([link acima](#antes-de-tudo-o-que-você-vai-entregar)). Preencha nome, RA, turma e data.
2. Entre no GitHub com a **sua conta**.
3. **Crie a sua cópia deste repositório:** acima da lista de arquivos desta página, ao lado do botão **Code**, clique no botão verde **Use this template → Create a new repository**. Em *Owner*, escolha a **sua conta**; dê um nome (por exemplo, `laboratorio-renovacao-certificado`) e clique em **Create repository**.
4. **Na sua cópia** (confira que o endereço no navegador começa com `github.com/SEU-USUARIO/`), clique no botão verde **Code → aba Codespaces → Create codespace on main**. Assim o Codespace fica na sua conta e usa a sua cota.
5. Aguarde: na primeira vez, a criação e a instalação do Caddy levam de 2 a 3 minutos. O editor abre no navegador, com este README à esquerda e um terminal embaixo.
6. Quando a instalação terminar, confira as versões:

```bash
caddy version
openssl version
```

> ✅ **CHECKPOINT 0** — O Codespace está aberto a partir da **sua cópia** do repositório (no GitHub, ele aparece em **Code → Codespaces** da sua cópia), o terminal mostrou a mensagem **"Ambiente pronto"**, a versão do Caddy começa com **v2** e a do OpenSSL com **3**.

### Etapa 1 — Subir o servidor (3 min)

No **terminal 1**:

```bash
caddy run --config Caddyfile 2>&1 | tee caddy.log
```

O terminal fica "preso" mostrando o log — é assim mesmo. **Deixe este terminal aberto até o fim da atividade.**

O log é escrito em linhas no formato JSON. Procure por:

- a criação da AC interna (`pki` e o nome `AC Cais Azul Lab`);
- a emissão do certificado de `agenda.caisazul.test` (as palavras `obtain` ou `certificate`).

> ✅ **CHECKPOINT 1** — O comando continua rodando, sem voltar para o prompt `$`, e nenhuma linha do log tem `"level":"error"`.
>
> Se aparecer um erro citando `renewal_window_ratio`, sua versão do Caddy é anterior a essa opção: apague essa linha do `Caddyfile` e rode o comando de novo.

> 📸 **EVIDÊNCIA 1 — O servidor no ar.** Print do terminal 1 com o comando `caddy run` e as linhas do log que falam da emissão do certificado de `agenda.caisazul.test`.

### Etapa 2 — Conhecer a AC interna (3 min)

Abra o **terminal 2** (botão **+**) e rode:

```bash
CA=~/.local/share/caddy/pki/authorities/local
openssl x509 -in $CA/root.crt         -noout -subject -dates
openssl x509 -in $CA/intermediate.crt -noout -subject -issuer -dates
```

> 💡 A variável `CA` vale só neste terminal. Se abrir outro terminal, rode a primeira linha de novo.

> ✅ **CHECKPOINT 2** — Aparecem dois blocos com `subject=` e as datas `notBefore`/`notAfter`. A **raiz** vence daqui a cerca de **10 anos**; a **intermediária**, daqui a **7 dias**. Os dois nomes contêm `AC Cais Azul Lab`.

> 📸 **EVIDÊNCIA 2 — A AC interna do Caddy.** Print do terminal 2 mostrando os nomes e as datas da raiz e da intermediária.

### Etapa 3 — Acessar o site (6 min)

Continue no **terminal 2**. Rode os três comandos abaixo, um de cada vez:

```bash
# 3.1 Sem confiar na AC do Caddy (como um navegador comum)
curl --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/
```

```bash
# 3.2 Confiando na raiz do Caddy (como um computador da empresa em que a TI instalou a raiz)
curl --cacert $CA/root.crt --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/
```

```bash
# 3.3 Os cabeçalhos da resposta
curl -sI --cacert $CA/root.crt --resolve agenda.caisazul.test:8443:127.0.0.1 https://agenda.caisazul.test:8443/
```

> 💡 `--resolve` faz o nome `agenda.caisazul.test` apontar para a própria máquina, sem editar arquivos do sistema.

> ✅ **CHECKPOINT 3** —
> - 3.1 terminou com erro: `curl: (60) SSL certificate problem…`;
> - 3.2 mostrou `PortalAgenda no ar. Hora do servidor: …`;
> - 3.3 mostrou a linha `strict-transport-security: max-age=31536000`.

> 📸 **EVIDÊNCIA 3 — Acessando o site.** Print do terminal 2 com os três resultados: o erro do 3.1, a página do 3.2 e a linha `strict-transport-security` do 3.3. Se não couber num print só, cole dois.

Agora veja o certificado que o servidor está entregando:

```bash
# 3.4 O certificado em uso
openssl s_client -connect 127.0.0.1:8443 -servername agenda.caisazul.test </dev/null 2>/dev/null \
  | openssl x509 -noout -serial -issuer -dates -ext subjectAltName
```

> ✅ **CHECKPOINT 4** — O emissor (`issuer`) contém `AC Cais Azul Lab`, aparece `DNS:agenda.caisazul.test` e a diferença entre `notBefore` e `notAfter` é de cerca de **10 minutos**.

> 📸 **EVIDÊNCIA 4 — O certificado de 10 minutos.** Print com o número de série, o emissor, as datas e o nome DNS.

> ❓ **PERGUNTA 1** — Por que o `curl` recusou a conexão em 3.1 e aceitou em 3.2? O que uma empresa faz para que **todos** os seus computadores confiem na própria AC interna?

### Etapa 4 — Assistir à renovação (8 a 10 min)

No **terminal 2**:

```bash
bash observar.sh
```

O script consulta o servidor a cada 15 segundos e mostra o certificado que ele está entregando naquele momento. **Deixe-o rodando também durante a Etapa 5.**

```text
hora      série (final)   validade   tempo de vida usado       restam
17:02:10  …8F31A07C2D11     10 min  [############........]  61%  3 min 54 s
17:02:25  …8F31A07C2D11     10 min  [#############.......]  64%  3 min 39 s
17:02:40  …8F31A07C2D11     10 min  [#############.......]  66%  3 min 24 s
17:02:55  …4B90E2D17A65     10 min  [....................]   1%  9 min 55 s   <<< CERTIFICADO NOVO
```

A barra vai enchendo. Quando chegar perto de **66%** (2/3), o Caddy troca o certificado e aparece a linha **`<<< CERTIFICADO NOVO`**, com outro número de série. No terminal 1, o log registra a renovação no mesmo instante.

> ✅ **CHECKPOINT 5** —
> - a barra chegou perto de 2/3 e apareceu **`<<< CERTIFICADO NOVO`**;
> - nenhuma linha mostrou *servidor não respondeu*: o site **não saiu do ar** durante a troca.
>
> A troca pode aparecer até cerca de 1 minuto depois dos 66%, porque o Caddy confere a validade a cada 30 s e o script consulta a cada 15 s.

> 📸 **EVIDÊNCIA 5 — A renovação automática.** Print do terminal 2 mostrando a barra perto de 2/3 e a linha `<<< CERTIFICADO NOVO`, com o número de série mudando.

> ❓ **PERGUNTA 2** — *(responda enquanto a barra enche)* Pela regra dos 2/3, depois de quantos dias seria renovado um certificado de **90 dias**? Quantos dias de folga sobrariam se a renovação falhasse?

### Etapa 5 — E se o servidor estiver desligado na hora da renovação? (8 min)

Mantenha o `observar.sh` rodando no terminal 2. Os passos abaixo são no **terminal 1**.

1. Espere o certificado atual chegar a cerca de **50%** de uso.
2. Pare o Caddy com **Ctrl + C** no terminal 1. O `observar.sh` passa a mostrar *servidor não respondeu*.
3. Espere cerca de **3 minutos**, até passar da marca de 2/3 — mas **antes** de completar os 10 minutos de validade.
4. Suba o Caddy de novo, com o mesmo comando da Etapa 1:

```bash
caddy run --config Caddyfile 2>&1 | tee caddy.log
```

Ao iniciar, o Caddy encontra o certificado guardado já dentro da janela de renovação e o troca logo em seguida.

> ✅ **CHECKPOINT 6** — No terminal 2 apareceram linhas *servidor não respondeu* enquanto o Caddy estava parado e, depois que ele voltou, uma linha **`<<< CERTIFICADO NOVO`**.

> 📸 **EVIDÊNCIA 6 — Servidor desligado e religado.** Print do terminal 2 mostrando as linhas *servidor não respondeu* e, logo depois, o site voltando com `<<< CERTIFICADO NOVO`.

### Etapa 6 — Encerrar e entregar (5 min)

> ❓ **PERGUNTA 3** — Este laboratório não mostrou uma das etapas do protocolo ACME. Qual é ela, e por que não aconteceu aqui? *(Dica: releia a Parte 1.)*

1. Pare o `observar.sh` (**Ctrl + C** no terminal 2) e o Caddy (**Ctrl + C** no terminal 1).
2. **Pare o Codespace** para não gastar a sua cota mensal: na **sua cópia** do repositório no GitHub, **Code → Codespaces → ⋯ → Stop codespace**. Depois de receber a nota, você pode excluí-lo.
3. Confira o documento de entrega:

> ✅ **CHECKPOINT FINAL**
> - [ ] As **6 evidências** estão coladas e legíveis.
> - [ ] A Evidência 5 mostra a linha `<<< CERTIFICADO NOVO`.
> - [ ] As **3 perguntas** estão respondidas.
> - [ ] Nome, RA, turma e data estão preenchidos.

4. Salve como **`Entrega-Renovacao-SeuNome.docx`** e envie na **tarefa do Teams**.

---

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| Não encontro o botão **Use this template** | Ele fica na página do repositório da disciplina, acima da lista de arquivos, ao lado do botão **Code**. É preciso estar logado no GitHub. |
| Criei o Codespace no repositório da disciplina, e não na minha cópia | Pare e exclua esse Codespace (**Code → Codespaces → ⋯ → Delete**), volte ao passo 3 da Etapa 0 e crie o Codespace a partir da sua cópia. |
| O Codespace não terminou de instalar ou não mostrou "Ambiente pronto" | Espere mais um pouco. Se o terminal mostrar erro, rode `bash .devcontainer/pos-criacao.sh`. |
| `caddy: command not found` | A instalação ainda não terminou ou falhou: rode `bash .devcontainer/pos-criacao.sh`. |
| O Caddy recusou a linha `renewal_window_ratio` | Apague essa linha do `Caddyfile` (o padrão já é 2/3) e suba o Caddy de novo. |
| `address already in use` ao subir o Caddy | Já existe um Caddy rodando em outro terminal. Pare-o com **Ctrl + C** ou rode `pkill caddy`. |
| `curl: (7) Failed to connect` ou *servidor não respondeu* fora da Etapa 5 | O Caddy não está rodando no terminal 1. Suba-o de novo (Etapa 1). |
| `$CA/root.crt: No such file` | A variável `CA` não existe neste terminal: rode `CA=~/.local/share/caddy/pki/authorities/local`. |
| O `observar.sh` está rodando e a troca não aparece | Espere a barra passar de 66%; a troca pode atrasar até cerca de 1 minuto. Confira se o Caddy continua no ar no terminal 1. |
| Perdi a primeira troca | Mantenha o `observar.sh` rodando: outra troca acontece cerca de 7 minutos depois. |
| O certificado venceu (100%) antes de religar o Caddy na Etapa 5 | Sem problema: suba o Caddy, espere a próxima troca e repita a Etapa 5. |

---

## Arquivos do repositório

| Arquivo | Para que serve |
|---|---|
| `README.md` | Este roteiro |
| `entrega/Modelo-Entrega-Renovacao-Certificado.docx` | Modelo do documento de entrega (evidências e perguntas) |
| `Caddyfile` | Configuração do servidor, comentada linha a linha |
| `observar.sh` | Mostra o certificado servido a cada 15 s e marca cada troca |
| `.devcontainer/` | Prepara o Codespace e instala o Caddy |

> ⚠️ **Somente laboratório:** a AC do Caddy existe só dentro do seu Codespace. Nunca instale a raiz de uma AC de laboratório no seu navegador do dia a dia.
