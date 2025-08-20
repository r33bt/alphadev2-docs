const fs = require('fs');
const path = require('path');

class SimpleWordPressConverter {
  constructor(xmlFilePath) {
    console.log('Reading XML file...');
    this.xmlContent = fs.readFileSync(xmlFilePath, 'utf8');
    console.log('XML file loaded, parsing items...');
  }

  extractItems() {
    const itemRegex = /<item>([\s\S]*?)<\/item>/g;
    const items = [];
    let match;
    
    while ((match = itemRegex.exec(this.xmlContent)) !== null) {
      items.push(match[1]);
    }
    
    console.log(`Found ${items.length} items to process`);
    return items;
  }

  extractField(itemContent, fieldName) {
    const regex = new RegExp(`<${fieldName}[^>]*>([\\s\\S]*?)<\\/${fieldName}>`, 'i');
    const match = itemContent.match(regex);
    return match ? match[1].trim() : '';
  }

  extractCDATA(content) {
    const cdataRegex = /<!\[CDATA\[([\s\S]*?)\]\]>/;
    const match = content.match(cdataRegex);
    return match ? match[1] : content;
  }

  cleanContent(htmlContent) {
    if (!htmlContent) return '';
    
    const cleanHtml = this.extractCDATA(htmlContent);
    
    return cleanHtml
      .replace(/<p>/g, '\n')
      .replace(/<\/p>/g, '\n')
      .replace(/<br\s*\/?>/g, '\n')
      .replace(/<strong>/g, '**')
      .replace(/<\/strong>/g, '**')
      .replace(/<em>/g, '*')
      .replace(/<\/em>/g, '*')
      .replace(/<h([1-6])>/g, (match, level) => `\n${'#'.repeat(parseInt(level))} `)
      .replace(/<\/h[1-6]>/g, '\n')
      .replace(/<[^>]*>/g, '')
      .replace(/\n\s*\n\s*\n/g, '\n\n')
      .trim();
  }

  createSlug(title) {
    return title
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }

  processItem(itemContent, index) {
    const title = this.extractCDATA(this.extractField(itemContent, 'title'));
    const postType = this.extractField(itemContent, 'wp:post_type');
    const status = this.extractField(itemContent, 'wp:status');
    const postName = this.extractField(itemContent, 'wp:post_name');
    const content = this.extractCDATA(this.extractField(itemContent, 'content:encoded'));
    const pubDate = this.extractField(itemContent, 'pubDate');
    
    if (status !== 'publish' || !title) {
      return null;
    }

    const slug = postName || this.createSlug(title);
    const date = pubDate ? new Date(pubDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0];
    
    const frontmatter = `---
title: "${title.replace(/"/g, '\\"')}"
slug: "${slug}"
date: "${date}"
type: "${postType}"
status: "${status}"
---

`;

    const cleanContent = this.cleanContent(content);
    
    return {
      type: postType,
      slug: slug,
      content: frontmatter + cleanContent
    };
  }

  convert() {
    console.log('Starting conversion...');
    
    const postsDir = './content/blog';
    const pagesDir = './content/pages';
    
    if (!fs.existsSync(postsDir)) {
      fs.mkdirSync(postsDir, { recursive: true });
    }
    if (!fs.existsSync(pagesDir)) {
      fs.mkdirSync(pagesDir, { recursive: true });
    }

    const items = this.extractItems();
    let postCount = 0;
    let pageCount = 0;
    let processedCount = 0;

    items.forEach((itemContent, index) => {
      if (index % 10 === 0) {
        console.log(`Processing item ${index + 1}/${items.length}`);
      }

      const processed = this.processItem(itemContent, index);
      if (!processed) return;

      processedCount++;
      const fileName = `${processed.slug}.mdx`;

      if (processed.type === 'post') {
        fs.writeFileSync(path.join(postsDir, fileName), processed.content);
        postCount++;
        if (postCount <= 5) console.log(`Created post: ${fileName}`);
      } else if (processed.type === 'page') {
        fs.writeFileSync(path.join(pagesDir, fileName), processed.content);
        pageCount++;
        if (pageCount <= 5) console.log(`Created page: ${fileName}`);
      }
    });

    console.log(`\nConversion completed!`);
    console.log(`Posts created: ${postCount}`);
    console.log(`Pages created: ${pageCount}`);
    console.log(`Total processed: ${processedCount}`);
  }
}

console.log('Starting WordPress XML to MDX conversion...');
const converter = new SimpleWordPressConverter('./wp-export/photosymphony-export.xml');
converter.convert();
