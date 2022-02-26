const InitializeSecrets = () => {
   const GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
   let secrets = {};
   for (const [key, value] of Object.entries(GITHUB_secrets)) {
      if (key !== "github_token") secrets[key] = JSON.parse(Buffer.from(value, "base64").toString("utf8"));
   }
   return secrets;
};
console.log("=====InitializeSecrets=====");
const secrets = InitializeSecrets();
console.log(JSON.stringify(secrets, null, "\t"));
console.log("=====END:InitializeSecrets=");
