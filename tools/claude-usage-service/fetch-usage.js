// Roda headless (chamado pelo systemd timer a cada N minutos). Abre o
// perfil salvo por login.js, visita claude.ai pra deixar a Cloudflare
// validar a sessão normalmente (como um navegador de verdade faria) e
// busca o endpoint interno de uso, gravando o resultado em outputFile.
//
// Se a sessão tiver expirado, não sobrescreve o arquivo (o widget continua
// mostrando o último valor bom conhecido) e só avisa no log pra rodar
// `npm run login` de novo.

const fs = require("fs");
const { chromium } = require("playwright");
const { dataDir, profileDir, outputFile } = require("./paths");
const { contextOptions } = require("./browser-context");

// ID da organização no claude.ai (Configurações → Uso → aba de rede mostra
// esse valor na URL do endpoint). Troque aqui se você usar outra conta/org.
const ORG_ID = "a874268f-9d05-4d33-9af0-1b4804e94a9e";

async function main() {
    if (!fs.existsSync(profileDir)) {
        console.error("Nenhuma sessão salva ainda. Rode primeiro: npm run login");
        process.exit(1);
    }

    const context = await chromium.launchPersistentContext(profileDir, contextOptions({ headless: true }));
    await context.addInitScript(() => {
        Object.defineProperty(navigator, "webdriver", { get: () => undefined });
    });

    try {
        const page = await context.newPage();
        await page.goto("https://claude.ai", { waitUntil: "domcontentloaded", timeout: 30000 });

        const result = await page.evaluate(async (orgId) => {
            const res = await fetch(`https://claude.ai/api/organizations/${orgId}/usage`, {
                credentials: "include",
            });
            return { status: res.status, body: await res.text() };
        }, ORG_ID);

        if (result.status !== 200) {
            console.error(`Sessão parece ter expirado (status ${result.status}). Rode: npm run login`);
            process.exit(1);
        }

        const data = JSON.parse(result.body);
        if (!data.five_hour || !data.seven_day) {
            console.error("Resposta inesperada da API de uso:", result.body);
            process.exit(1);
        }

        fs.mkdirSync(dataDir, { recursive: true });
        const tmpFile = outputFile + ".tmp";
        fs.writeFileSync(tmpFile, JSON.stringify(data));
        fs.renameSync(tmpFile, outputFile);

        console.log(`Uso atualizado: sessão ${Math.round(data.five_hour.utilization)}%, semana ${Math.round(data.seven_day.utilization)}%`);
    } finally {
        await context.close();
    }
}

main().catch((err) => {
    console.error("Falha ao buscar uso:", err);
    process.exit(1);
});
