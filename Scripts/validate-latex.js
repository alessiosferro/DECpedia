// Optional offline check: node Scripts/validate-latex.js (no npm install).
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const katex = require(path.join(root, 'Sources/DECpedia/Resources/MathAssets/katex.min.js'));
const catalog = JSON.parse(fs.readFileSync(path.join(root, 'Sources/DECpedia/Resources/catalog.json'), 'utf8'));
let checked = 0;
const failures = [];
function validate(tex, location) {
  checked++;
  try { katex.renderToString(tex, { throwOnError: true, trust: false, strict: 'ignore' }); }
  catch (error) { failures.push(`${location}: ${error.message}`); }
}
for (const entry of catalog.concepts) {
  const texts = [entry.summary, entry.summaryEN];
  for (const block of entry.blocks) {
    texts.push(block.text, block.textEN);
    if (block.latex) validate(block.latex, `${entry.id}/${block.id}`);
  }
  for (const text of texts) {
    for (const match of text.matchAll(/\\\(([\s\S]*?)\\\)|\\\[([\s\S]*?)\\\]/g)) {
      validate(match[1] ?? match[2], entry.id);
    }
  }
}

const games = JSON.parse(fs.readFileSync(path.join(root, 'Sources/DECpedia/Resources/games.json'), 'utf8'));
function checkGameText(value, location) {
  if (typeof value === 'string') {
    for (const match of value.matchAll(/\\\(([\s\S]*?)\\\)|\\\[([\s\S]*?)\\\]/g)) validate(match[1] ?? match[2], location);
  } else if (value && typeof value === 'object') {
    for (const [key, child] of Object.entries(value)) checkGameText(child, `${location}/${key}`);
  }
}
checkGameText(games, 'logic-games');

console.log(`${checked} LaTeX expressions checked; ${failures.length} errors.`);
for (const error of failures) console.error(error);
process.exitCode = failures.length ? 1 : 0;
