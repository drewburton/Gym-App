const fs = require('fs');
const path = require('path');

const agentsDir = '.gemini/agents';
const files = fs.readdirSync(agentsDir).filter(f => f.endsWith('.md'));

for (const file of files) {
  const filePath = path.join(agentsDir, file);
  const content = fs.readFileSync(filePath, 'utf8');
  const frontmatterMatch = content.match(/^---
([\s\S]*?)
---/);
  
  if (!frontmatterMatch) {
    console.error(`ERROR: No frontmatter found in ${file}`);
    continue;
  }
  
  const frontmatterStr = frontmatterMatch[1];
  console.log(`Checking ${file}...`);
  try {
    // Simple YAML-ish parser since we don't have a full YAML parser installed
    // Actually, I'll just check for some common issues
    if (frontmatterStr.includes('\u2014')) {
        console.warn(`WARNING: Possible problematic character in ${file}: \u2014`);
    }
  } catch (err) {
    console.error(`ERROR parsing ${file}: ${err.message}`);
  }
}
