const GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
for (const [key, value] of Object.entries(GITHUB_secrets)) {
   console.log(`${key}: ${value}`);
   GITHUB_secrets[key] = Buffer.from(value, "base64").toString("utf8");
}
console.log(JSON.stringify(GITHUB_secrets));
