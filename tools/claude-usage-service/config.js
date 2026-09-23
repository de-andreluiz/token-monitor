// Config específica de cada pessoa que usa o serviço: o ID da organização
// no claude.ai. NUNCA fica hardcoded no código nem commitado — cada usuário
// aponta pra própria conta.
//
// Como descobrir o seu ORG_ID:
//   1. Abra claude.ai → Configurações → Uso
//   2. Abra o DevTools do navegador → aba Rede (Network)
//   3. Recarregue a página e procure a requisição para
//      /api/organizations/<ORG_ID>/usage
//   4. Copie o <ORG_ID> que aparece na URL
//
// Defina de UMA das duas formas:
//   a) Variável de ambiente:  export CLAUDE_ORG_ID="seu-id-aqui"
//   b) Arquivo local:  ~/.local/share/llm-quota-widget/config.json
//                       { "orgId": "seu-id-aqui" }

const fs = require("fs");
const path = require("path");
const { dataDir } = require("./paths");

const configFile = path.join(dataDir, "config.json");

function loadOrgId() {
    if (process.env.CLAUDE_ORG_ID) {
        return process.env.CLAUDE_ORG_ID;
    }
    if (fs.existsSync(configFile)) {
        try {
            const parsed = JSON.parse(fs.readFileSync(configFile, "utf8"));
            if (parsed.orgId) return parsed.orgId;
        } catch (e) {
            console.error(`Não consegui ler ${configFile}: ${e.message}`);
        }
    }
    return null;
}

const orgId = loadOrgId();

if (!orgId) {
    console.error(
        "ORG_ID não configurado.\n\n" +
            "Defina de uma das duas formas:\n" +
            "  export CLAUDE_ORG_ID=\"seu-id-aqui\"\n" +
            "ou crie o arquivo:\n" +
            `  ${configFile}\n` +
            '  { "orgId": "seu-id-aqui" }\n\n' +
            "Como achar o seu ORG_ID: claude.ai → Configurações → Uso → DevTools →\n" +
            "aba Rede, procure a requisição /api/organizations/<ORG_ID>/usage."
    );
    process.exit(1);
}

module.exports = { orgId };
