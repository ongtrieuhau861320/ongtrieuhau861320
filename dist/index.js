console.log(JSON.stringify(process.env));
let GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
console.log(Buffer.from(GITHUB_secrets.TEST01, "base64").toString("utf8"));
console.log(Buffer.from(GITHUB_secrets.TEST02).toString("base64"));
