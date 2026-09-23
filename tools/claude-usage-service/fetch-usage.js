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
const { orgId } = require("./config");
const { contextOptions } = require("./browser-context");

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
            return {
                status: res.status,
                body: await res.text(),
                contentType: res.headers.get("content-type") || "",
            };
        }, orgId);

        if (result.status !== 200) {
            console.error(
                `Requisição falhou com status ${result.status}. Isso pode ser:\n` +
                    "  - sessão expirada -> rode: npm run login\n" +
                    "  - ORG_ID incorreto/de outra conta -> confira a config (veja config.js)"
            );
            process.exit(1);
        }

        let data;
        try {
            data = JSON.parse(result.body);
        } catch (parseErr) {
            console.error(
                "Resposta não é JSON válido — provavelmente a verificação anti-bot da\n" +
                    "Cloudflare interceptou a requisição (página de desafio) em vez do\n" +
                    "endpoint de uso. Tente rodar de novo em alguns segundos; se persistir,\n" +
                    "refaça o login: npm run login\n" +
                    "Início da resposta recebida: " + result.body.slice(0, 200)
            );
            process.exit(1);
        }

        if (!data.five_hour || !data.seven_day) {
            console.error("Resposta inesperada da API de uso (formato mudou?):", result.body);
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
