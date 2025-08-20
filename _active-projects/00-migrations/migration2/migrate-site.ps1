Write-Host "WordPress to Static Site Migration" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Step 1: Export WordPress content
Write-Host "Step 1: Exporting WordPress content..." -ForegroundColor Yellow
node scripts/wp-export.js

# Step 2: Download media files  
Write-Host "Step 2: Downloading media files..." -ForegroundColor Yellow
node scripts/download-media.js

# Step 3: Transform content to MDX
Write-Host "Step 3: Transforming content to MDX..." -ForegroundColor Yellow
node scripts/wp-to-mdx.js

# Step 4: Copy content to Next.js project
Write-Host "Step 4: Copying content to Next.js project..." -ForegroundColor Yellow
if (Test-Path "content") {
    xcopy content my-migrated-site\content /E /I /Y
}
if (Test-Path "public") {
    xcopy public my-migrated-site\public /E /I /Y  
}

# Step 5: Install Next.js dependencies
Write-Host "Step 5: Installing Next.js dependencies..." -ForegroundColor Yellow
cd my-migrated-site
npm install @next/mdx @mdx-js/loader @mdx-js/react gray-matter reading-time

# Step 6: Build and test
Write-Host "Step 6: Building Next.js site..." -ForegroundColor Yellow
npm run build

Write-Host "Migration completed!" -ForegroundColor Green
Write-Host "Run 'npm run dev' to test locally" -ForegroundColor Cyan
