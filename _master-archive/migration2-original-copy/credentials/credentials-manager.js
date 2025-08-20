const fs = require('fs');
const path = require('path');
require('dotenv').config();

class CredentialsManager {
  constructor() {
    this.credentialsDir = __dirname;
    this.envPath = path.join(this.credentialsDir, '.env');
  }

  // Load all credentials
  loadCredentials(siteSpecificPath = null) {
    console.log('🔑 Loading credentials...');
    
    // Load global credentials
    if (fs.existsSync(this.envPath)) {
      require('dotenv').config({ path: this.envPath });
      console.log('✅ Global credentials loaded');
    } else {
      console.log('⚠️  Global .env file not found');
    }

    // Load site-specific credentials if provided
    if (siteSpecificPath && fs.existsSync(siteSpecificPath)) {
      require('dotenv').config({ path: siteSpecificPath });
      console.log('✅ Site-specific credentials loaded');
    }

    return process.env;
  }

  // Validate required credentials for deployment
  validateDeploymentCredentials() {
    const required = [
      'VERCEL_TOKEN',
      'GITHUB_TOKEN',
      'GITHUB_USERNAME',
      'WP_ADMIN_URL',
      'WP_USERNAME',
      'WP_PASSWORD'
    ];

    const missing = required.filter(key => !process.env[key]);

    if (missing.length > 0) {
      console.log('❌ Missing required credentials:');
      missing.forEach(key => console.log(`   - ${key}`));
      return false;
    }

    console.log('✅ All deployment credentials present');
    return true;
  }

  // Get WordPress config object
  getWordPressConfig() {
    return {
      wpUrl: process.env.WP_ADMIN_URL?.replace('/wp-admin', ''),
      username: process.env.WP_USERNAME,
      password: process.env.WP_PASSWORD,
      siteName: process.env.SITE_NAME || process.env.WP_SITE_NAME
    };
  }

  // Get Vercel config
  getVercelConfig() {
    return {
      token: process.env.VERCEL_TOKEN,
      orgId: process.env.VERCEL_ORG_ID,
      projectId: process.env.VERCEL_PROJECT_ID
    };
  }

  // Get GitHub config
  getGitHubConfig() {
    return {
      token: process.env.GITHUB_TOKEN,
      username: process.env.GITHUB_USERNAME,
      email: process.env.GITHUB_EMAIL
    };
  }

  // Create site-specific env file
  createSiteEnv(siteName, overrides = {}) {
    const siteEnvPath = path.join(this.credentialsDir, `${siteName}.env`);
    
    const template = `# ${siteName.toUpperCase()} SITE CREDENTIALS
SITE_NAME=${siteName}
SITE_URL=https://${siteName}.vercel.app
VERCEL_PROJECT_NAME=${siteName}-blog
GITHUB_REPO_NAME=${siteName}-migration

# WordPress Source (update these)
WP_ADMIN_URL=https://old-${siteName}.com/wp-admin
WP_USERNAME=admin
WP_PASSWORD=your_password

# Site-specific overrides
${Object.entries(overrides).map(([key, value]) => `${key}=${value}`).join('\n')}
`;

    fs.writeFileSync(siteEnvPath, template);
    console.log(`✅ Created site-specific env: ${siteEnvPath}`);
    return siteEnvPath;
  }

  // Setup credentials for current project
  setupForProject(projectPath) {
    const projectEnvPath = path.join(projectPath, '.env.local');
    
    // Copy relevant credentials to project
    const projectEnv = `# Auto-generated from credentials manager
VERCEL_TOKEN=${process.env.VERCEL_TOKEN || ''}
GITHUB_TOKEN=${process.env.GITHUB_TOKEN || ''}
OPENAI_API_KEY=${process.env.OPENAI_API_KEY || ''}
NEXT_PUBLIC_SITE_URL=${process.env.NEXT_PUBLIC_SITE_URL || ''}
`;

    fs.writeFileSync(projectEnvPath, projectEnv);
    console.log(`✅ Project credentials setup: ${projectEnvPath}`);
  }
}

module.exports = CredentialsManager;

// CLI usage
if (require.main === module) {
  const manager = new CredentialsManager();
  const args = process.argv.slice(2);
  
  if (args[0] === 'validate') {
    manager.loadCredentials();
    manager.validateDeploymentCredentials();
  } else if (args[0] === 'create-site' && args[1]) {
    manager.loadCredentials();
    manager.createSiteEnv(args[1]);
  } else {
    console.log('Usage:');
    console.log('  node credentials-manager.js validate');
    console.log('  node credentials-manager.js create-site <site-name>');
  }
}
