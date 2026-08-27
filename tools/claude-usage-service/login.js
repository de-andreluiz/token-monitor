// Abre um Chromium DE VERDADE (com janela) apontado pra um perfil próprio
// e persistente. Faça login no claude.ai normalmente aqui uma vez; a sessão
// (incluindo o cookie de validação da Cloudflare) fica salva nesse perfil
// e é reaproveitada pelo fetch-usage.js daí em diante — sem precisar copiar
// cookie nenhum manualmente.
//
// Rode de novo sempre que o login expirar (o script de fetch avisa quando
// isso acontece).

const fs = require("fs");
const { chromium } = require("playwright");
const { dataDir, profileDir } = require("./paths");

async function main() {
    fs.mkdirSync(dataDir, { recursive: true });

    const context = await chromium.launchPersistentContext(profileDir, {
        headless: false,
        viewport: { width: 1200, height: 800 },
    });

    const page = context.pages()[0] || (await context.newPage());
    await page.goto("https://claude.ai");

    console.log("Faça login normalmente na janela do Chromium.");
    console.log("Quando terminar (ver a tela normal de conversas do Claude), feche a janela do navegador para salvar a sessão.");

    await context.waitForEvent("close", { timeout: 0 });
}

main().catch((err) => {
    console.error("Falha no login:", err);
    process.exit(1);
});
