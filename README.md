# Token Monitor

Widget nativo para **KDE Plasma 6** que mostra, direto no seu desktop, quanto
da sua cota de uso do **Claude**, **Codex** (OpenAI) ou **Gemini** (Google)
você já consumiu — sessão atual e limite semanal, com horário de reset e
tudo.

Inspirado num widget Android (Jetpack Glance/Compose) feito originalmente
para uso pessoal, recriado aqui como um plasmoid QML para quem vive no
Plasma.

<p align="center">
  <img src="https://img.shields.io/badge/KDE%20Plasma-6-1D99F3?logo=kde&logoColor=white" alt="KDE Plasma 6">
  <img src="https://img.shields.io/badge/QML-Declarative-41CD52?logo=qt&logoColor=white" alt="QML">
  <img src="https://img.shields.io/badge/status-em%20desenvolvimento-yellow" alt="Status">
</p>

---

## ✨ Funcionalidades

- **Multi-provedor**: alterne entre Claude, Codex e Gemini a qualquer
  momento — cada um com seu ícone, logotipo oficial e cor de destaque.
- **Cards de uso**: sessão atual e limite semanal, com barra de progresso
  animada, percentual e horário/tempo até o próximo reset.
- **Tema claro/escuro independente**, com cor de fundo customizável por
  tema através de uma roda de cores (matiz, saturação e brilho).
- **Ícone compacto em painéis**: no desktop mostra o card completo; num
  painel ou bandeja do sistema, mostra só o ícone e abre o card num popup
  ao clicar.
- **Dados reais do Claude** — sem precisar de API key nem guardar nenhuma
  credencial em disco (veja [como funciona](#-como-os-dados-reais-do-claude-funcionam)
  abaixo).

## 📦 Instalação

Requer KDE Plasma **6.0+**.

```bash
git clone https://github.com/de-andreluiz/token-monitor.git
kpackagetool6 --type Plasma/Applet --install token-monitor
```

Depois é só clicar com o botão direito no desktop ou num painel →
**Adicionar widgets…** → procurar por **"LLM Quota Monitor"**.

### Atualizando uma instalação existente

```bash
git pull
kpackagetool6 --type Plasma/Applet --upgrade token-monitor
```

Se a mudança não aparecer, reinicie a shell gráfica:

```bash
kquitapp6 plasmashell; kstart plasmashell
```

## ⚙️ Configuração

Clique com o botão direito no widget → **Configurar Widget…** para:

- Escolher o provedor (Claude / Codex / Gemini).
- Alternar entre tema Claro e Escuro.
- Escolher a cor de fundo do card (independente por tema).

## 🔌 Como os dados reais do Claude funcionam

O Claude não oferece uma API pública para consultar "quanto da minha
assinatura Pro/Max eu já usei" — esse dado só existe na tela **Configurações
→ Uso** do próprio claude.ai, atendida por um endpoint interno e não
documentado, autenticado pela sessão logada no navegador (e protegido por
verificação anti-bot da Cloudflare).

Pra não depender de copiar cookie manualmente (nem de ficar repetindo isso
toda vez que a verificação expira), o Token Monitor usa um **serviço local**
em [`tools/claude-usage-service`](tools/claude-usage-service): um Chromium
controlado via [Playwright](https://playwright.dev/), com um perfil próprio
onde você faz login **uma vez**. Um timer do `systemd --user` roda esse
Chromium headless a cada ~10 minutos, deixando a verificação da Cloudflare
se renovar sozinha (como um navegador de verdade faria) e salvando o
resultado em `~/.local/share/llm-quota-widget/claude-usage.json`. O widget
só lê esse arquivo — nenhum cookie passa pela mão do widget em si.

**Configuração (uma vez só):**

```bash
cd tools/claude-usage-service
./install.sh        # instala dependências, o Chromium do Playwright e o timer
npm run login        # abre uma janela pra você logar no claude.ai
```

Depois disso é só usar o widget normalmente — o arquivo de uso se mantém
atualizado sozinho em segundo plano. Veja mais detalhes, incluindo como
checar os logs, no [README do serviço](tools/claude-usage-service/README.md).

> Como não é uma API oficial, esse endpoint pode mudar ou parar de
> funcionar sem aviso a qualquer momento — se isso acontecer, o widget
> volta a mostrar os últimos valores conhecidos, e o serviço avisa nos logs
> que é preciso rodar `npm run login` de novo.

Codex e Gemini ainda **não têm** integração de dados reais — por enquanto
mostram valores de exemplo fixos.

## 🗂️ Estrutura do projeto

```
contents/
├── config/
│   ├── config.qml        # Registro da tela de configuração
│   └── main.xml           # Schema das chaves de configuração (kcfg)
├── images/                 # Ícones e logotipos oficiais (SVG)
└── ui/
    ├── main.qml             # Widget principal
    ├── ColorWheel.qml        # Roda de cores (matiz/saturação/brilho)
    ├── ProviderIcon.qml       # Ícone do provedor, com fallback
    ├── ProviderWordmark.qml   # Logotipo do provedor, com fallback
    ├── Providers.js            # Lista de provedores (fonte única)
    ├── RoundedProgressBar.qml   # Barra de progresso customizada
    ├── UsageCard.qml             # Card reutilizável (sessão/semana)
    └── config/
        └── ConfigGeneral.qml      # Tela "Configurar Widget…"
metadata.json
tools/
├── claude-usage-service/          # Serviço local (login + fetch periódico)
│   ├── install.sh                  # Instala dependências e o timer do systemd
│   ├── login.js                     # Login manual (uma vez), salva a sessão
│   ├── fetch-usage.js                # Busca o uso e grava o JSON local
│   └── systemd/                       # Unit files do timer/service
└── RESUMO-DO-PROJETO.txt          # Changelog detalhado do projeto
```

## 🧭 Roteiro

- [ ] Integração de dados reais para Codex (ChatGPT/OpenAI).
- [ ] Integração de dados reais para Gemini (Google).
- [ ] Ícone dedicado do plasmoid (hoje usa um ícone genérico do sistema).

## 🤝 Contribuindo

Issues e PRs são bem-vindos. Este é um projeto pessoal, então respostas
podem demorar um pouco.
