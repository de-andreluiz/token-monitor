# claude-usage-service

Serviço local que mantém uma sessão logada no claude.ai e busca
periodicamente os dados de uso, pra o Token Monitor ler direto de um
arquivo — sem precisar copiar cookie nem clicar em nada no dia a dia.

## Como funciona

- `login.js` abre um Chromium **com janela**, usando um perfil próprio em
  `~/.local/share/llm-quota-widget/browser-profile`. Você loga normalmente
  no claude.ai; a sessão fica salva nesse perfil.
- `fetch-usage.js` abre o mesmo perfil, mas **headless**, visita o
  claude.ai (deixando a verificação anti-bot da Cloudflare se renovar
  sozinha) e busca o endpoint interno de uso, salvando o resultado em
  `~/.local/share/llm-quota-widget/claude-usage.json`.
- Um timer do `systemd --user` (`claude-usage-fetch.timer`) roda o
  `fetch-usage.js` a cada ~10 minutos automaticamente.

Nenhuma credencial fica no repositório: tudo isso mora fora dele, em
`~/.local/share/llm-quota-widget`.

## Instalação

```bash
./install.sh
npm run login
```

O `install.sh` instala as dependências (`npm install`), baixa o Chromium
do Playwright e registra + ativa o timer do systemd. O `npm run login`
abre a janela pra você fazer login — feche a janela quando terminar.

## Comandos úteis

```bash
# Ver se o timer está ativo e quando roda de novo
systemctl --user status claude-usage-fetch.timer
systemctl --user list-timers claude-usage-fetch.timer

# Rodar a busca manualmente (sem esperar o timer)
systemctl --user start claude-usage-fetch.service

# Ver os logs
journalctl --user -u claude-usage-fetch.service -f

# Logar de novo quando a sessão expirar (o log avisa quando isso acontece)
npm run login
```

## Desinstalando

```bash
systemctl --user disable --now claude-usage-fetch.timer
rm ~/.config/systemd/user/claude-usage-fetch.service
rm ~/.config/systemd/user/claude-usage-fetch.timer
systemctl --user daemon-reload
rm -rf ~/.local/share/llm-quota-widget
```
