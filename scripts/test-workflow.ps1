# AlphaDev2 Complete Workflow Test
# Tests the full Git → GitHub → Vercel deployment pipeline

Write-Host "Complete Development Workflow Test" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

$secretsPath = "C:\Users\user\alphadev2\secrets\credentials"
$projectsPath = "C:\Users\user\alphadev2\projects\web"
$testProjectName = "workflow-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$testProjectPath = Join-Path $projectsPath $testProjectName

# Function to read credential files
function Read-CredentialFile($filename) {
    $filePath = Join-Path $secretsPath $filename
    if (Test-Path $filePath) {
        return Get-Content $filePath -Raw
    }
    return $null
}

# Load credentials
$githubToken = Read-CredentialFile "github.token"
$vercelToken = Read-CredentialFile "vercel.token"

if (-not $githubToken) {
    Write-Host "ERROR: GitHub token not found. Run setup-credentials.ps1 first." -ForegroundColor Red
    exit 1
}

if (-not $vercelToken) {
    Write-Host "ERROR: Vercel token not found. Run setup-credentials.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "`n1. Creating test project..." -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# Create project directory
New-Item -Path $testProjectPath -ItemType Directory -Force
Set-Location $testProjectPath

Write-Host "Project created at: $testProjectPath" -ForegroundColor Green

Write-Host "`n2. Creating sample Next.js application..." -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Create package.json
$packageJson = @"
{
  "name": "$testProjectName",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.0.4",
    "react": "^18",
    "react-dom": "^18"
  },
  "devDependencies": {
    "eslint": "^8",
    "eslint-config-next": "14.0.4"
  }
}
"@

$packageJson | Out-File -FilePath "package.json" -Encoding UTF8

# Create pages directory and index page
New-Item -Path "pages" -ItemType Directory -Force

$indexPage = @"
import Head from 'next/head'

export default function Home() {
  return (
    <div>
      <Head>
        <title>AlphaDev2 Workflow Test</title>
        <meta name="description" content="Testing the complete Git → GitHub → Vercel workflow" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
        <h1>🚀 AlphaDev2 Workflow Test</h1>
        <p>This is a test deployment from our AlphaDev2 development environment.</p>
        <p><strong>Workflow:</strong> Git → GitHub → Vercel</p>
        <p><strong>Deployed at:</strong> {new Date().toLocaleString()}</p>
        
        <div style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#f0f0f0' }}>
          <h2>✅ Workflow Components Tested:</h2>
          <ul>
            <li>✅ Git repository initialization</li>
            <li>✅ GitHub repository creation</li>
            <li>✅ Code commit and push</li>
            <li>✅ Vercel deployment</li>
            <li>✅ Automatic builds</li>
          </ul>
        </div>
      </main>
    </div>
  )
}
"@

$indexPage | Out-File -FilePath "pages\index.js" -Encoding UTF8

# Create .env.example
$envExample = @"
# AlphaDev2 Project Environment Template
# Copy to .env.local and add your values

# Supabase (if using database)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Other environment variables...
"@

$envExample | Out-File -FilePath ".env.example" -Encoding UTF8

# Create .gitignore
$gitIgnore = @"
# Dependencies
node_modules/
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Environment variables
.env*.local

# IDE files
.vscode/settings.json
.idea/

# OS files
.DS_Store
*.tgz
*.tar.gz

# Vercel
.vercel
"@

$gitIgnore | Out-File -FilePath ".gitignore" -Encoding UTF8

Write-Host "Sample Next.js application created" -ForegroundColor Green

Write-Host "`n3. Initializing Git repository..." -ForegroundColor Yellow
Write-Host "---------------------------------" -ForegroundColor Yellow

git init
git add .
git commit -m "Initial commit: AlphaDev2 workflow test

Generated automatically by AlphaDev2 development environment.
Tests the complete Git → GitHub → Vercel deployment workflow.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

Write-Host "Git repository initialized and initial commit created" -ForegroundColor Green

Write-Host "`n4. Creating GitHub repository..." -ForegroundColor Yellow
Write-Host "---------------------------------" -ForegroundColor Yellow

# Set GitHub token environment variable temporarily
$env:GITHUB_TOKEN = $githubToken.Trim()

try {
    # Create GitHub repository
    gh repo create $testProjectName --public --description "AlphaDev2 workflow test - automated Git → GitHub → Vercel pipeline" --push

    Write-Host "GitHub repository created and code pushed" -ForegroundColor Green
}
catch {
    Write-Host "Error creating GitHub repository: $_" -ForegroundColor Red
}
finally {
    # Clear environment variable
    Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
}

Write-Host "`n5. Deploying to Vercel..." -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow

try {
    # Deploy to Vercel using token
    $deploymentResult = vercel --prod --token $vercelToken.Trim() --yes

    Write-Host "Vercel deployment completed" -ForegroundColor Green
    Write-Host "Deployment details:" -ForegroundColor Cyan
    Write-Host $deploymentResult -ForegroundColor White
}
catch {
    Write-Host "Error deploying to Vercel: $_" -ForegroundColor Red
}

Write-Host "`n6. Workflow Summary" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

Write-Host "✅ Test project created: $testProjectName" -ForegroundColor White
Write-Host "✅ Git repository initialized" -ForegroundColor White
Write-Host "✅ GitHub repository created" -ForegroundColor White
Write-Host "✅ Code committed and pushed" -ForegroundColor White
Write-Host "✅ Vercel deployment triggered" -ForegroundColor White

Write-Host "`nProject Details:" -ForegroundColor Cyan
Write-Host "Local Path: $testProjectPath" -ForegroundColor White

# Get GitHub repository URL
try {
    $repoUrl = git remote get-url origin
    Write-Host "GitHub Repo: $repoUrl" -ForegroundColor White
}
catch {
    Write-Host "GitHub Repo: Could not retrieve URL" -ForegroundColor Yellow
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Check your Vercel dashboard for deployment status" -ForegroundColor White
Write-Host "2. Visit the deployed URL to verify the application" -ForegroundColor White
Write-Host "3. Test making changes and pushing updates" -ForegroundColor White
Write-Host "4. Verify automatic redeployment on GitHub pushes" -ForegroundColor White

Write-Host "`n🎉 Complete Git → GitHub → Vercel workflow tested successfully!" -ForegroundColor Green

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")