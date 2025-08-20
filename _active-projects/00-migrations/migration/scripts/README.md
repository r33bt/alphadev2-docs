# Migration Automation Scripts

Simple scripts to automate headless WordPress migrations and prevent the issues we encountered with StockTiming and Wedding Planner migrations.

## Quick Usage

For a complete migration, just run:

```bash
./migrate-site.sh the-weddingplanner.com "The Wedding Planner" "Expert Wedding Planning & Celebration Ideas"
```

## What Each Script Does

### `migrate-site.sh` - Complete Migration
- Runs all steps in correct order
- Stops on any error
- Provides clear progress updates

### `setup-wordpress.sh` - WordPress Configuration  
- Fixes WordPress URLs for staging
- Deactivates Wordfence plugin
- Creates application password
- Tests API connection

### `customize-template.sh` - Template Customization
- Copies StockTiming template
- Replaces ALL hardcoded StockTiming references
- Validates no references remain
- Prevents wrong branding issues

### `setup-environment.sh` - Environment Variables
- Creates .env.production file
- Sets Vercel environment variables  
- Tests WordPress API connection
- Prevents deployment failures

## Prerequisites

Make sure these exist:
- `C:\Users\user\.ssh\gridpane_rsa` (SSH key)
- `C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token`
- Staging site accessible at `staging.yourdomain.com`

## Testing the Scripts

Before using the scripts on a real migration, you can test them:

### Quick Template Test
```bash
./test-template-only.sh
```
Tests the template customization logic (removes StockTiming branding).

### Validation Check  
```bash
./validate-setup.sh yourdomain.com
```
Checks if all prerequisites are in place before migration.

### Full Test Suite
```bash
./test-migration.sh
```
Runs comprehensive tests on all scripts.

## Manual Steps After Migration

1. Configure DNS for your domain to point to Vercel
2. Test the site once DNS propagates

That's it!