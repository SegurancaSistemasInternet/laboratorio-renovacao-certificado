# Evidências

Esta pasta recebe as saídas gravadas durante o roteiro e entregues no commit:

| Arquivo | Gerado na | Comando |
|---|---|---|
| `certificado.txt` | etapa 3.4 | `openssl s_client … \| openssl x509 … \| tee evidencias/certificado.txt` |
| `renovacao.txt` | etapas 4 e 5 | `bash observar.sh \| tee evidencias/renovacao.txt` |

Os dois arquivos contêm apenas informações **públicas** do certificado (nome, emissor, datas, número de série). As chaves privadas do Caddy ficam em `~/.local/share/caddy`, fora do repositório, e nunca devem ser copiadas para cá.
