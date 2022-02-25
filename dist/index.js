console.log(JSON.stringify(process.env));
let GITHUB_secrets = JSON.parse(process.env.GITHUB_secrets);
const insertToString = (sourceText, index, insertText) => {
   return sourceText.slice(0, index) + insertText + sourceText.slice(index);
};
console.log(insertToString(GITHUB_secrets.TEST01, 4, "~~~~~"));
console.log(insertToString(GITHUB_secrets.TEST02, 4, "~~~~~"));
