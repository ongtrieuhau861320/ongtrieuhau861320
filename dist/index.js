console.log("=====InitializeSecrets=====");
const GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
for (const [key, value] of Object.entries(GITHUB_secrets)) {
   if (key !== "github_token") GITHUB_secrets[key] = Buffer.from(value, "base64").toString("utf8");
}
console.log(JSON.stringify(GITHUB_secrets, null, "\t"));
console.log("=====END:InitializeSecrets=");
