console.log(JSON.stringify(process.env));
console.log(Buffer.from(process.env.TEST01, "base64").toString("utf8"));
console.log(Buffer.from(process.env.TEST01).toString("base64"));
