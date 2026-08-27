#!/usr/bin/env bash
# Instala dependências, o Chromium do Playwright e registra o timer do
# systemd --user que mantém o arquivo de uso do Claude atualizado sozinho.
set -euo pipefail

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIT_DIR="$HOME/.config/systemd/user"

echo "==> Instalando dependências (npm install)"
cd "$SERVICE_DIR"
npm install

echo "==> Baixando o Chromium do Playwright"
npx playwright install chromium

echo "==> Registrando serviço no systemd --user"
mkdir -p "$UNIT_DIR"
sed "s|__SERVICE_DIR__|$SERVICE_DIR|" "$SERVICE_DIR/systemd/claude-usage-fetch.service" > "$UNIT_DIR/claude-usage-fetch.service"
cp "$SERVICE_DIR/systemd/claude-usage-fetch.timer" "$UNIT_DIR/claude-usage-fetch.timer"

systemctl --user daemon-reload
systemctl --user enable --now claude-usage-fetch.timer

echo
echo "==> Falta só o login (janela do navegador vai abrir):"
echo "    npm run login"
echo
echo "Depois disso o timer já cuida do resto (busca a cada 10 min)."
echo "Pra ver os logs:  journalctl --user -u claude-usage-fetch.service -f"
