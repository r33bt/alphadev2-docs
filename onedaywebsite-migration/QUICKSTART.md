# 🚀 Quick Start Guide
## WordPress to Vercel Migration in 3 Steps

### Prerequisites ✅
- Node.js 18+ installed
- Git installed  
- Internet connection
- ✅ **Credentials already in secrets folder!**

### Step 1: Automated Setup (2 minutes)
```bash
# Navigate to project (already done)
cd onedaywebsite-migration

# Run complete setup (loads credentials automatically)
npm run setup
```

The setup script will:
- ✅ Install dependencies
- ✅ **Load all credentials from ../secrets/credentials**
- ✅ Generate complete `.env` file with all tokens
- ✅ Set script permissions
- ✅ Verify all credentials loaded

**No manual token configuration needed!** 🎉

### Step 2: Run Migration (10-30 minutes)
```bash
# Option A: Run complete migration
npm run migrate

# Option B: Run step by step
npm run analyze     # Analyze WordPress site (2-5 min)
npm run extract     # Extract content (5-15 min) 
npm run generate    # Generate Next.js site (2-5 min)
npm run deploy      # Deploy to Vercel (3-8 min)
```

### Step 3: Verify & Go Live (5 minutes)
1. ✅ Check deployment URL (shown in terminal)
2. ✅ Test all pages load correctly
3. ✅ Verify contact forms work
4. ✅ Update DNS to point to Vercel (if ready)

## What Gets Created
- 📁 **Complete Next.js site** with all WordPress content
- 🎨 **Modern responsive design** with Tailwind CSS
- ⚡ **Optimized performance** (sub-2 second loads)
- 📱 **Mobile-friendly** layouts
- 🔍 **SEO-optimized** with proper meta tags
- 🚀 **Auto-deployed** to Vercel with custom domain support

## Troubleshooting

### "Command not found" errors
```bash
# Install missing CLI tools
npm install -g vercel@latest
# For GitHub CLI, see: https://cli.github.com/
```

### Authentication issues  
```bash
# Re-authenticate services
gh auth login
vercel login
```

### Permission denied (Linux/Mac)
```bash
chmod +x scripts/*.sh scripts/utils/*.sh
```

### Content extraction fails
- Check if onedaywebsite.org is accessible
- Verify internet connection
- Try running `npm run analyze` first

## Expected Results
- ✅ **55+ blog posts** migrated
- ✅ **2+ pages** migrated  
- ✅ **All images** downloaded and optimized
- ✅ **Categories/tags** preserved
- ✅ **SEO metadata** maintained
- ✅ **Performance score** 90+ on PageSpeed

## Get Help
- 📖 Check `docs/setup-guide.md` for detailed instructions
- 📝 Review `setup-log.txt` for setup details  
- 🔍 Check `data/migration-log.txt` for migration logs

Ready to migrate? Run `npm run setup` to begin!