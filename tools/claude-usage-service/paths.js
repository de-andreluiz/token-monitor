// Caminhos compartilhados entre login.js e fetch-usage.js.
// Tudo fica fora do repositório, em ~/.local/share, pra nunca versionar
// nada de sessão/credencial por acidente.

const os = require("os");
const path = require("path");

const dataDir = path.join(os.homedir(), ".local", "share", "llm-quota-widget");
const profileDir = path.join(dataDir, "browser-profile");
const outputFile = path.join(dataDir, "claude-usage.json");

module.exports = { dataDir, profileDir, outputFile };
