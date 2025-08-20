const fs = require('fs');
const https = require('https');
const http = require('http');
const path = require('path');
const { URL } = require('url');

class MediaDownloader {
  constructor(exportData) {
    this.media = exportData.media;
    this.downloadDir = './public/images';
    this.mediaMap = new Map(); // Original URL -> Local path mapping
  }

  async downloadFile(url, localPath) {
    return new Promise((resolve, reject) => {
      const dir = path.dirname(localPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      const client = url.startsWith('https://') ? https : http;
      const file = fs.createWriteStream(localPath);
      
      client.get(url, (response) => {
        response.pipe(file);
        file.on('finish', () => {
          file.close();
          resolve(localPath);
        });
      }).on('error', (err) => {
        fs.unlink(localPath, () => {}); // Delete partial file
        reject(err);
      });
    });
  }

  async downloadAllMedia() {
    console.log(`Starting download of ${this.media.length} media files...`);
    
    for (let i = 0; i < this.media.length; i++) {
      const mediaItem = this.media[i];
      const sourceUrl = mediaItem.source_url;
      
      try {
        const urlObj = new URL(sourceUrl);
        const fileName = path.basename(urlObj.pathname);
        const localPath = path.join(this.downloadDir, fileName);
        
        console.log(`[${i+1}/${this.media.length}] Downloading: ${fileName}`);
        await this.downloadFile(sourceUrl, localPath);
        
        // Store mapping for content transformation
        this.mediaMap.set(sourceUrl, `/images/${fileName}`);
        
      } catch (error) {
        console.error(`Failed to download ${sourceUrl}:`, error.message);
      }
    }
    
    // Save media mapping
    fs.writeFileSync('./wp-export/media-map.json', JSON.stringify(Object.fromEntries(this.mediaMap), null, 2));
    console.log('Media download completed!');
  }
}

// Usage
const exportData = JSON.parse(fs.readFileSync('./wp-export/content-export.json', 'utf8'));
const downloader = new MediaDownloader(exportData);
downloader.downloadAllMedia().catch(console.error);
