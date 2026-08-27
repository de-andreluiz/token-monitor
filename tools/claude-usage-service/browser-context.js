// Opções compartilhadas de lançamento do Chromium. O principal aqui é
// disfarçar que é o Playwright: por padrão ele liga uma flag de automação
// que o Chromium expõe via CDP, e a Cloudflare usa isso pra ficar te
// jogando num loop infinito de "verificando se você é humano".

const REALISTIC_USER_AGENT =
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36";

function contextOptions(extra) {
    return Object.assign(
        {
            userAgent: REALISTIC_USER_AGENT,
            viewport: { width: 1280, height: 800 },
            locale: "pt-BR",
            args: ["--disable-blink-features=AutomationControlled"],
            ignoreDefaultArgs: ["--enable-automation"],
        },
        extra
    );
}

module.exports = { contextOptions };
