.pragma library

// Lista de provedores suportados: id usado na config,
// nome exibido, glifo do cabeçalho e cor de destaque.
// Caminho das imagens relativo a contents/ui/ (onde ProviderIcon.qml e
// ProviderWordmark.qml vivem) — único lugar que precisa saber essa estrutura.
var imagesDir = "../images/";

var list = [
    { id: "claude", name: "Claude", glyph: "✳️", color: "#d97757", icon: imagesDir + "claude.svg", wordmark: imagesDir + "claude-text.svg" },
    { id: "codex", name: "Codex", glyph: "◐", color: "#6366f1", icon: imagesDir + "codex.svg", wordmark: imagesDir + "codex-text.svg" },
    { id: "gemini", name: "Gemini", glyph: "✦", color: "#4285f4", icon: imagesDir + "gemini.svg", wordmark: imagesDir + "gemini-text.svg" }
];

function byId(id) {
    for (var i = 0; i < list.length; i++) {
        if (list[i].id === id) {
            return list[i];
        }
    }
    return list[0];
}
