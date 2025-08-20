const fs = require('fs');
const path = require('path');

// Check all MDX files for issues
const contentDir = './content';
const issues = [];

function validateDirectory(dir) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      validateDirectory(filePath);
    } else if (file.endsWith('.mdx')) {
      try {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Check frontmatter
        if (!content.startsWith('---')) {
          issues.push(`${filePath}: Missing frontmatter`);
        }
        
        // Check for broken image links
        const imageMatches = content.match(/!\[.*?\]\((.*?)\)/g);
        if (imageMatches) {
          imageMatches.forEach(match => {
            const imagePath = match.match(/\((.*?)\)/)[1];
            if (imagePath.startsWith('/images/')) {
              const fullPath = `./public${imagePath}`;
              if (!fs.existsSync(fullPath)) {
                issues.push(`${filePath}: Missing image ${imagePath}`);
              }
            }
          });
        }
        
      } catch (error) {
        issues.push(`${filePath}: Parse error - ${error.message}`);
      }
    }
  });
}

validateDirectory(contentDir);

if (issues.length === 0) {
  console.log('✅ All content validated successfully!');
} else {
  console.log('❌ Issues found:');
  issues.forEach(issue => console.log(`  - ${issue}`));
}
