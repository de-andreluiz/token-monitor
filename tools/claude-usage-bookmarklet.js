// Bookmarklet: cole o conteúdo minificado abaixo como URL de um favorito do
// Firefox (o navegador salva "javascript:..." como um favorito normal).
// Ao clicar nele estando aberto em claude.ai, ele busca os limites de uso
// da sua conta (mesma chamada da tela Configurações > Uso) e copia o JSON
// pro clipboard — depois é só clicar no botão de refresh do widget.
//
// Não precisa rodar isso num console; é só pra referência/manutenção.
// A versão pronta pra colar como URL do favorito está em claude-usage-bookmarklet.txt

(function () {
    var orgId = "a874268f-9d05-4d33-9af0-1b4804e94a9e";
    fetch("https://claude.ai/api/organizations/" + orgId + "/usage", { credentials: "include" })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            return navigator.clipboard.writeText(JSON.stringify(data));
        })
        .then(function () {
            alert("Uso do Claude copiado! Agora clique no refresh do widget.");
        })
        .catch(function (e) {
            alert("Falha ao buscar uso do Claude: " + e);
        });
})();
