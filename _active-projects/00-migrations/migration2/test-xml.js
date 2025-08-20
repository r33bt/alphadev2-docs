const fs = require('fs');

console.log('Testing XML file...');
try {
  const xmlContent = fs.readFileSync('./wp-export/photosymphony-export.xml', 'utf8');
  console.log('XML file size:', xmlContent.length, 'characters');
  console.log('First 500 characters:', xmlContent.substring(0, 500));
  console.log('XML file loaded successfully!');
} catch (error) {
  console.error('Error reading XML file:', error.message);
}
