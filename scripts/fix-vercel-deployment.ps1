# Fix Vercel Deployment Issues
# This script helps troubleshoot and fix common Vercel deployment problems

Write-Host "Vercel Deployment Troubleshooting" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$vercelToken = "5aD1vf5YifXj5oak2JZjO1Wb"

# Find the test project directory
$projectsPath = "C:\Users\user\alphadev2\projects\web"
$testProjects = Get-ChildItem -Path $projectsPath -Directory | Where-Object { $_.Name.StartsWith("workflow-test-") }

if ($testProjects.Count -eq 0) {
    Write-Host "No workflow test projects found. Run test-workflow.ps1 first." -ForegroundColor Red
    exit 1
}

# Use the most recent test project
$latestProject = $testProjects | Sort-Object CreationTime -Descending | Select-Object -First 1
$projectPath = $latestProject.FullName
$projectName = $latestProject.Name

Write-Host "Found test project: $projectName" -ForegroundColor Green
Write-Host "Project path: $projectPath" -ForegroundColor White

Set-Location $projectPath

Write-Host "`n1. Checking current project status..." -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow

# Check if .vercel directory exists (means project is linked)
if (Test-Path ".vercel") {
    Write-Host "✅ Project is linked to Vercel" -ForegroundColor Green
} else {
    Write-Host "❌ Project not linked to Vercel" -ForegroundColor Red
}

# Check if package.json exists
if (Test-Path "package.json") {
    Write-Host "✅ package.json found" -ForegroundColor Green
} else {
    Write-Host "❌ package.json missing" -ForegroundColor Red
}

Write-Host "`n2. Installing dependencies..." -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

try {
    npm install
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install dependencies: $_" -ForegroundColor Red
}

Write-Host "`n3. Testing local build..." -ForegroundColor Yellow
Write-Host "--------------------------" -ForegroundColor Yellow

try {
    npm run build
    Write-Host "✅ Local build successful" -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Build failed or no build script found. This might be why deployment failed." -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host "`n4. Checking Vercel project status..." -ForegroundColor Yellow
Write-Host "-------------------------------------" -ForegroundColor Yellow

# Check deployments
$deployments = vercel list --token $vercelToken --yes 2>&1
Write-Host "Vercel project status:" -ForegroundColor White
Write-Host $deployments -ForegroundColor Gray

Write-Host "`n5. Attempting deployment..." -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

Write-Host "Deploying to preview environment first..." -ForegroundColor Cyan
try {
    $previewDeploy = vercel --token $vercelToken --yes
    Write-Host "✅ Preview deployment triggered" -ForegroundColor Green
    Write-Host $previewDeploy -ForegroundColor White
    
    Write-Host "`nNow deploying to production..." -ForegroundColor Cyan
    $prodDeploy = vercel --prod --token $vercelToken --yes
    Write-Host "✅ Production deployment triggered" -ForegroundColor Green
    Write-Host $prodDeploy -ForegroundColor White
}
catch {
    Write-Host "❌ Deployment failed: $_" -ForegroundColor Red
    Write-Host "`nTrying alternative deployment method..." -ForegroundColor Yellow
    
    try {
        # Try with force flag
        $forceDeploy = vercel --prod --token $vercelToken --yes --force
        Write-Host "✅ Force deployment successful" -ForegroundColor Green
        Write-Host $forceDeploy -ForegroundColor White
    }
    catch {
        Write-Host "❌ Force deployment also failed: $_" -ForegroundColor Red
    }
}

Write-Host "`n6. Final status check..." -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow

# Check deployments again
$finalStatus = vercel list --token $vercelToken --yes 2>&1
Write-Host "Final deployment status:" -ForegroundColor White
Write-Host $finalStatus -ForegroundColor Gray

Write-Host "`n7. Summary and Next Steps" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "Project: $projectName" -ForegroundColor White
Write-Host "Location: $projectPath" -ForegroundColor White

Write-Host "`nIf deployment succeeded, you should see:" -ForegroundColor Cyan
Write-Host "- Preview URL (for testing)" -ForegroundColor White  
Write-Host "- Production URL (live site)" -ForegroundColor White

Write-Host "`nIf deployment is still failing:" -ForegroundColor Yellow
Write-Host "1. Check Vercel dashboard: https://vercel.com/dashboard" -ForegroundColor White
Write-Host "2. Look for build logs and error messages" -ForegroundColor White
Write-Host "3. Verify environment variables if needed" -ForegroundColor White
Write-Host "4. Try manual deployment from Vercel dashboard" -ForegroundColor White

Write-Host "`nCommon deployment issues:" -ForegroundColor Yellow
Write-Host "- Missing dependencies (npm install)" -ForegroundColor White
Write-Host "- Build script failures (npm run build)" -ForegroundColor White
Write-Host "- Missing environment variables" -ForegroundColor White
Write-Host "- Framework detection issues" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")