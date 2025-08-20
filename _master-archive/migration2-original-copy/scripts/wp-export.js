const fs = require('fs');
const https = require('https');
const path = require('path');

const SITE_URL = 'https://photosymphony.com'; // Replace with target site
const API_BASE = `${SITE_URL}/wp-json/wp/v2`;

class WordPressExporter {
  constructor() {
    this.content = {
      posts: [],
      pages: [],
      categories: [],
      tags: [],
      media: []
    };
  }

  async fetchAPI(endpoint, page = 1, perPage = 100) {
    return new Promise((resolve, reject) => {
      const url = `${API_BASE}/${endpoint}?page=${page}&per_page=${perPage}&_embed`;
      
      https.get(url, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            const totalPages = parseInt(res.headers['x-wp-totalpages'] || '1');
            resolve({ data: json, totalPages, currentPage: page });
          } catch (e) {
            reject(e);
          }
        });
      }).on('error', reject);
    });
  }

  async fetchAllPages(endpoint) {
    let allItems = [];
    let currentPage = 1;
    let totalPages = 1;

    do {
      console.log(`Fetching ${endpoint} - Page ${currentPage}/${totalPages}`);
      const result = await this.fetchAPI(endpoint, currentPage);
      allItems = allItems.concat(result.data);
      totalPages = result.totalPages;
      currentPage++;
    } while (currentPage <= totalPages);

    return allItems;
  }

  async exportContent() {
    console.log('Starting WordPress export...');
    
    // Export posts
    this.content.posts = await this.fetchAllPages('posts');
    console.log(`Exported ${this.content.posts.length} posts`);
    
    // Export pages
    this.content.pages = await this.fetchAllPages('pages');
    console.log(`Exported ${this.content.pages.length} pages`);
    
    // Export categories
    this.content.categories = await this.fetchAllPages('categories');
    console.log(`Exported ${this.content.categories.length} categories`);
    
    // Export tags
    this.content.tags = await this.fetchAllPages('tags');
    console.log(`Exported ${this.content.tags.length} tags`);
    
    // Export media
    this.content.media = await this.fetchAllPages('media');
    console.log(`Exported ${this.content.media.length} media items`);
    
    // Save to file
    const outputDir = './wp-export';
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    fs.writeFileSync(
      path.join(outputDir, 'content-export.json'),
      JSON.stringify(this.content, null, 2)
    );
    
    console.log('Export completed! Check ./wp-export/content-export.json');
    return this.content;
  }
}

// Run export
const exporter = new WordPressExporter();
exporter.exportContent().catch(console.error);
