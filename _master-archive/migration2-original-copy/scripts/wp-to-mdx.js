const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

class ContentTransformer {
  constructor() {
    this.exportData = JSON.parse(fs.readFileSync('./wp-export/content-export.json', 'utf8'));
    this.mediaMap = JSON.parse(fs.readFileSync('./wp-export/media-map.json', 'utf8'));
    this.categoryMap = new Map();
    this.tagMap = new Map();
    
    // Build lookup maps
    this.exportData.categories.forEach(cat => {
      this.categoryMap.set(cat.id, cat.name);
    });
    this.exportData.tags.forEach(tag => {
      this.tagMap.set(tag.id, tag.name);
    });
  }

  cleanContent(htmlContent) {
    const dom = new JSDOM(htmlContent);
    const document = dom.window.document;
    
    // Replace WordPress image URLs with local paths
    const images = document.querySelectorAll('img');
    images.forEach(img => {
      const src = img.getAttribute('src');
      if (this.mediaMap[src]) {
        img.setAttribute('src', this.mediaMap[src]);
      }
    });
    
    // Convert to markdown-friendly HTML
    let cleanHtml = document.body.innerHTML;
    
    // Basic HTML to Markdown conversions
    cleanHtml = cleanHtml
      .replace(/<p>/g, '\n')
      .replace(/<\/p>/g, '\n')
      .replace(/<br\s*\/?>/g, '\n')
      .replace(/<strong>/g, '**')
      .replace(/<\/strong>/g, '**')
      .replace(/<em>/g, '*')
      .replace(/<\/em>/g, '*')
      .replace(/<h([1-6])>/g, (match, level) => `\n${'#'.repeat(parseInt(level))} `)
      .replace(/<\/h[1-6]>/g, '\n');
    
    return cleanHtml.trim();
  }

  createFrontmatter(item, type) {
    const categories = (item.categories || []).map(id => this.categoryMap.get(id)).filter(Boolean);
    const tags = (item.tags || []).map(id => this.tagMap.get(id)).filter(Boolean);
    
    const frontmatter = {
      title: item.title.rendered,
      slug: item.slug,
      date: item.date,
      modified: item.modified,
      status: item.status,
      type: type,
      ...(item.excerpt?.rendered && { excerpt: item.excerpt.rendered.replace(/<[^>]*>/g, '') }),
      ...(categories.length && { categories }),
      ...(tags.length && { tags }),
      ...(item.featured_media && { featuredImage: this.getFeaturedImagePath(item.featured_media) }),
      ...(item.yoast_head_json && {
        seo: {
          title: item.yoast_head_json.title,
          description: item.yoast_head_json.description,
          focusKeyword: item.yoast_head_json.focus_keyword
        }
      })
    };
    
    return `---\n${Object.entries(frontmatter)
      .filter(([key, value]) => value !== undefined && value !== null)
      .map(([key, value]) => {
        if (Array.isArray(value)) {
          return `${key}:\n${value.map(v => `  - "${v}"`).join('\n')}`;
        } else if (typeof value === 'object') {
          return `${key}:\n${Object.entries(value).map(([k, v]) => `  ${k}: "${v}"`).join('\n')}`;
        } else {
          return `${key}: "${value}"`;
        }
      })
      .join('\n')}\n---\n\n`;
  }

  getFeaturedImagePath(mediaId) {
    const mediaItem = this.exportData.media.find(m => m.id === mediaId);
    return mediaItem ? this.mediaMap[mediaItem.source_url] : null;
  }

  transformPosts() {
    const postsDir = './content/blog';
    if (!fs.existsSync(postsDir)) {
      fs.mkdirSync(postsDir, { recursive: true });
    }

    this.exportData.posts.forEach(post => {
      const frontmatter = this.createFrontmatter(post, 'post');
      const content = this.cleanContent(post.content.rendered);
      const mdxContent = `${frontmatter}${content}`;
      
      const fileName = `${post.slug}.mdx`;
      fs.writeFileSync(path.join(postsDir, fileName), mdxContent);
      console.log(`Created: ${fileName}`);
    });
  }

  transformPages() {
    const pagesDir = './content/pages';
    if (!fs.existsSync(pagesDir)) {
      fs.mkdirSync(pagesDir, { recursive: true });
    }

    this.exportData.pages.forEach(page => {
      const frontmatter = this.createFrontmatter(page, 'page');
      const content = this.cleanContent(page.content.rendered);
      const mdxContent = `${frontmatter}${content}`;
      
      const fileName = `${page.slug}.mdx`;
      fs.writeFileSync(path.join(pagesDir, fileName), mdxContent);
      console.log(`Created: ${fileName}`);
    });
  }

  generateMetadata() {
    const metadata = {
      categories: Object.fromEntries(this.categoryMap),
      tags: Object.fromEntries(this.tagMap),
      postsCount: this.exportData.posts.length,
      pagesCount: this.exportData.pages.length,
      exportDate: new Date().toISOString()
    };
    
    fs.writeFileSync('./content/metadata.json', JSON.stringify(metadata, null, 2));
  }

  transform() {
    console.log('Starting content transformation...');
    this.transformPosts();
    this.transformPages();
    this.generateMetadata();
    console.log('Transformation completed!');
  }
}

// Run transformation
const transformer = new ContentTransformer();
transformer.transform();
