#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Verificação automática da entrega do laboratório de renovação automática.
#
# Uso (na raiz do repositório):   bash scripts/verificar.sh
#
# O mesmo script roda no GitHub Actions a cada push (.github/workflows/).
# Ele confere as evidências em evidencias/, a configuração do Caddyfile,
# as respostas do ENTREGA.md e se nenhum segredo foi enviado ao Git.
# ---------------------------------------------------------------------------
set -u
cd "$(dirname "$0")/.." || exit 2

ok=0
falhas=0
passou() { echo "  ✓ $1"; ok=$((ok + 1)); }
falhou() {
  echo "  ✗ $1"
  [ -n "${2:-}" ] && echo "      dica: $2"
  falhas=$((falhas + 1))
}
titulo() { echo; echo "▸ $1"; }

# ---------------------------------------------------------------- segredos
titulo "Segredos fora do Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  versionados=$(git ls-files | grep -Ei '\.(key|pfx|p12)$' || true)
  com_chave=$(git grep -l -e 'PRIVATE KEY-----' -- . 2>/dev/null | grep -v '^scripts/verificar.sh$' || true)
  if [ -z "$versionados$com_chave" ]; then
    passou "nenhuma chave privada no repositório"
  else
    falhou "há segredo versionado: $(echo "$versionados $com_chave" | tr '\n' ' ')" \
      "remova com 'git rm --cached <arquivo>'. As chaves do Caddy ficam em ~/.local/share/caddy e não devem vir para cá."
  fi
else
  echo "  (não é um repositório Git; verificação de segredos ignorada)"
fi

# ---------------------------------------------------------------- Caddyfile
titulo "Configuração (Caddyfile)"
if grep -Eq '^[[:space:]]*tls[[:space:]]+internal' Caddyfile; then passou "usa a AC interna (tls internal)"; else falhou "falta 'tls internal' no Caddyfile"; fi
if grep -Eq '^[[:space:]]*lifetime[[:space:]]+10m' Caddyfile; then passou "certificado do site com validade de 10 minutos"; else falhou "o lifetime deveria ser 10m" "desfaça alterações dos desafios com 'git checkout Caddyfile'."; fi

# ---------------------------------------------------------------- certificado.txt
titulo "Evidência da etapa 3 (evidencias/certificado.txt)"
C=evidencias/certificado.txt
if [ ! -s "$C" ]; then
  falhou "arquivo não encontrado ou vazio" "refaça a etapa 3.4, que termina com '| tee evidencias/certificado.txt'."
else
  if grep -q 'DNS:agenda.caisazul.test' "$C"; then passou "certificado de agenda.caisazul.test"; else falhou "o subjectAltName de agenda.caisazul.test não aparece"; fi
  if grep -Eq '^issuer=.*AC Cais Azul Lab' "$C"; then passou "emitido pela AC interna do laboratório"; else falhou "o emissor deveria ser a AC 'AC Cais Azul Lab'"; fi
  ini=$(grep '^notBefore=' "$C" | cut -d= -f2-)
  fim=$(grep '^notAfter=' "$C" | cut -d= -f2-)
  if [ -n "$ini" ] && [ -n "$fim" ]; then
    min=$(( ( $(date -d "$fim" +%s) - $(date -d "$ini" +%s) ) / 60 ))
    if [ "$min" -ge 5 ] && [ "$min" -le 20 ]; then passou "validade de vida curta: $min minutos"; else falhou "validade de $min minutos; esperado cerca de 10"; fi
  else
    falhou "datas notBefore/notAfter não encontradas"
  fi
fi

# ---------------------------------------------------------------- renovacao.txt
titulo "Evidência das etapas 4 e 5 (evidencias/renovacao.txt)"
R=evidencias/renovacao.txt
if [ ! -s "$R" ]; then
  falhou "arquivo não encontrado ou vazio" "refaça a etapa 4: bash observar.sh | tee evidencias/renovacao.txt"
else
  trocas=$(grep -c 'CERTIFICADO NOVO' "$R" || true)
  if [ "${trocas:-0}" -ge 1 ]; then
    passou "renovação observada: $trocas troca(s) de certificado"
  else
    falhou "nenhuma troca de certificado registrada" "deixe o observar.sh rodando até aparecer '<<< CERTIFICADO NOVO'."
  fi
  leituras=$(grep -Ec '^[0-9]{2}:[0-9]{2}:[0-9]{2} ' "$R" || true)
  if [ "${leituras:-0}" -ge 20 ]; then passou "$leituras leituras registradas"; else falhou "só ${leituras:-0} leituras; esperado ao menos 20 (cerca de 5 minutos de observação)"; fi
fi

# ---------------------------------------------------------------- respostas
titulo "Respostas (ENTREGA.md)"
pend=$(grep -c '_(responda aqui)_' ENTREGA.md 2>/dev/null || true)
pend=${pend:-0}
if [ "$pend" = 0 ]; then passou "todas as perguntas respondidas"; else falhou "ainda há $pend item(ns) com '(responda aqui)' em ENTREGA.md"; fi

echo
echo "Resultado: $ok verificação(ões) ok, $falhas falha(s)."
[ "$falhas" = 0 ] && echo "Entrega completa. 🎉"
[ "$falhas" = 0 ]
