#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Observa, em intervalos regulares, o certificado que o servidor está
# entregando AGORA, e marca quando ele é trocado por um novo.
#
# Uso:  bash observar.sh            (consulta a cada 15 s)
#       bash observar.sh 5          (consulta a cada 5 s)
# Interromper: Ctrl + C
# A hora mostrada é a do Codespace (UTC, 3 horas à frente de Brasília).
# ---------------------------------------------------------------------------
HOST=agenda.caisazul.test
PORTA=8443
INTERVALO=${1:-15}
anterior=""

printf '%-8s  %-14s  %-9s  %-24s  %s\n' "hora" "série (final)" "validade" "tempo de vida usado" "restam"
while true; do
  pem=$(openssl s_client -connect 127.0.0.1:$PORTA -servername $HOST </dev/null 2>/dev/null | openssl x509 2>/dev/null)
  if [ -z "$pem" ]; then
    printf '%-8s  servidor não respondeu\n' "$(date +%T)"
    sleep "$INTERVALO"; continue
  fi
  serie=$(openssl x509 -noout -serial <<<"$pem" | cut -d= -f2)
  ini=$(date -d "$(openssl x509 -noout -startdate <<<"$pem" | cut -d= -f2)" +%s)
  fim=$(date -d "$(openssl x509 -noout -enddate <<<"$pem" | cut -d= -f2)" +%s)
  agora=$(date +%s)
  total=$((fim - ini)); [ "$total" -le 0 ] && total=1
  usado=$(( (agora - ini) * 100 / total ))
  [ "$usado" -gt 100 ] && usado=100
  cheios=$(( usado / 5 ))
  barra=$(printf '%*s' "$cheios" '' | tr ' ' '#')$(printf '%*s' $((20 - cheios)) '' | tr ' ' '.')
  restam=$(( fim - agora ))
  if [ "$restam" -le 0 ]; then resta_txt="VENCIDO"; else resta_txt="$((restam / 60)) min $((restam % 60)) s"; fi
  marca=""
  if [ -n "$anterior" ] && [ "$serie" != "$anterior" ]; then marca="   <<< CERTIFICADO NOVO"; fi
  printf '%-8s  %-14s  %5d min  [%s] %3d%%  %s%s\n' "$(date +%T)" "…${serie: -12}" $((total / 60)) "$barra" "$usado" "$resta_txt" "$marca"
  anterior=$serie
  sleep "$INTERVALO"
done
