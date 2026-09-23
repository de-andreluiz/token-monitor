.pragma library

// Lista de provedores suportados: id usado na config,
// nome exibido, glifo do cabeçalho e cor de destaque.
// Caminho das imagens relativo a contents/ui/ (onde ProviderIcon.qml e
// ProviderWordmark.qml vivem) — único lugar que precisa saber essa estrutura.
//
// Por enquanto só o Claude tem integração de dados reais (veja
// tools/claude-usage-service). Codex e Gemini foram removidos daqui por
// enquanto — pra reativar no futuro, basta acrescentar de volta um objeto
// com id/name/glyph/color/icon/wordmark nesta lista.
var imagesDir = "../images/";

var list = [
    { id: "claude", name: "Claude", glyph: "✳️", color: "#d97757", icon: imagesDir + "claude.svg", wordmark: imagesDir + "claude-text.svg" }
];

function byId(id) {
    for (var i = 0; i < list.length; i++) {
        if (list[i].id === id) {
            return list[i];
        }
    }
    return list[0];
}
