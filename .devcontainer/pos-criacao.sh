#!/usr/bin/env bash
# Executado uma única vez, quando o Codespace é criado.
# Instala o Caddy pelo repositório oficial (caddyserver.com/docs/install),
# além do jq (para ler o log) e do OpenSSL.
set -e
sudo apt-get update -y
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl gnupg jq openssl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  | sudo gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  | sudo tee /etc/apt/sources.list.d/caddy-stable.list >/dev/null
sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt-get update -y
sudo apt-get install -y caddy
chmod +x observar.sh
echo
echo "============================================================"
echo " Ambiente pronto: Caddy $(caddy version | cut -d' ' -f1) · $(openssl version)"
echo " Siga o README.md (Etapa 0, Checkpoint 0)"
echo "============================================================"
