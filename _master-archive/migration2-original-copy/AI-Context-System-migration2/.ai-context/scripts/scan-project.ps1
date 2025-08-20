param([string]$OutputPath)

if (-not $OutputPath) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputPath = ".ai-context\snapshots\scan-$timestamp.md"
}

Write-Host "Scanning Next.js project structure..." -ForegroundColor Yellow

# Define Next.js key directories and files to scan
$keyDirectories = @('src', 'app', 'pages', 'components', 'lib', 'utils', 'styles', 'public', 'supabase')
$keyFiles = @('package.json', 'next.config.js', 'tailwind.config.js', '.env.local', '.env.example', 'middleware.ts', 'middleware.js')
$excludePatterns = @('node_modules', '.next', '.git', 'dist', 'build', '.vercel')

function Get-ProjectStructure {
    $structure = @()
    
    # Scan key directories
    foreach ($dir in $keyDirectories) {
        if (Test-Path $dir) {
            $structure += "## 📁 $dir/"
            $files = Get-ChildItem -Path $dir -Recurse -File | Where-Object { 
                $_.Extension -match '\.(tsx?|jsx?|css|scss|json|md|sql)$' 
            } | Select-Object -First 20
            
            foreach ($file in $files) {
                $relativePath = $file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
                $structure += "- $relativePath"
            }
            $structure += ""
        }
    }
    
    return $structure -join "`n"
}

function Get-KeyConfigurations {
    $configs = @()
    
    # Package.json info
    if (Test-Path 'package.json') {
        $pkg = Get-Content 'package.json' | ConvertFrom-Json
        $configs += "## 📦 Package Configuration"
        $configs += "**Project**: $($pkg.name) v$($pkg.version)"
        $configs += "**Scripts**:"
        $pkg.scripts.PSObject.Properties | ForEach-Object { 
            $configs += "- ``$($_.Name)``: $($_.Value)" 
        }
        $configs += ""
        
        $configs += "**Key Dependencies**:"
        if ($pkg.dependencies) {
            $pkg.dependencies.PSObject.Properties | Select-Object -First 10 | ForEach-Object {
                $configs += "- $($_.Name): $($_.Value)"
            }
        }
        $configs += ""
    }
    
    # Next.js config
    if (Test-Path 'next.config.js') {
        $configs += "## ⚙️ Next.js Configuration"
        $configs += "- next.config.js present"
    }
    
    # Tailwind config
    if (Test-Path 'tailwind.config.js') {
        $configs += "- tailwind.config.js present"
    }
    
    # Environment files
    $envFiles = Get-ChildItem -Filter '.env*' -Force | Select-Object Name
    if ($envFiles) {
        $configs += "## 🔐 Environment Files"
        $envFiles | ForEach-Object { $configs += "- $($_.Name)" }
        $configs += ""
    }
    
    return $configs -join "`n"
}

function Get-RouteStructure {
    $routes = @()
    
    # App Router (Next.js 13+)
    if (Test-Path 'src/app') {
        $routes += "## 🛣️ App Router Structure"
        $appFiles = Get-ChildItem -Path 'src/app' -Recurse -File | Where-Object { 
            $_.Name -match '(page|layout|loading|error|not-found)\.(tsx?|jsx?)$' 
        }
        foreach ($file in $appFiles) {
            $route = $file.DirectoryName.Replace((Resolve-Path 'src/app').Path, '').Replace('\', '/')
            if ($route -eq '') { $route = '/' }
            $routes += "- $route -> $($file.Name)"
        }
    }
    
    # Pages Router (Legacy)
    if (Test-Path 'pages') {
        $routes += "## 📄 Pages Router Structure"
        $pageFiles = Get-ChildItem -Path 'pages' -Recurse -Filter '*.tsx', '*.jsx', '*.ts', '*.js'
        foreach ($file in $pageFiles) {
            $route = $file.FullName.Replace((Resolve-Path 'pages').Path, '').Replace('\', '/').Replace($file.Extension, '')
            $routes += "- $route -> $($file.Name)"
        }
    }
    
    return $routes -join "`n"
}

$content = @"
# Intelligent Next.js Project Scan
*Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*

## 🎯 Project Type Detection
$(if (Test-Path 'next.config.js') { "**Detected**: Next.js Application" } else { "**Type**: General Web Project" })
$(if (Test-Path 'vercel.json') { "**Deployment**: Vercel" } else { "" })
$(if (Test-Path 'supabase') { "**Database**: Supabase" } else { "" })

## 📊 Git Status
**Branch**: $(git branch --show-current 2>$null)
**Status**: 
$(git status --porcelain 2>$null | Select-Object -First 5)

## 🏗️ Project Structure
$(Get-ProjectStructure)

$(Get-KeyConfigurations)

$(Get-RouteStructure)

## 📈 Development Statistics
- **Components**: $(Get-ChildItem -Recurse -Filter '*.tsx' | Where-Object { $_.FullName -notmatch '(node_modules|\.next)' } | Measure-Object | Select-Object -ExpandProperty Count) React components
- **Pages/Routes**: $(Get-ChildItem -Recurse -Name | Where-Object { $_ -match '(page|layout)\.(tsx?|jsx?)$' } | Measure-Object | Select-Object -ExpandProperty Count) route files
- **Stylesheets**: $(Get-ChildItem -Recurse -Filter '*.css' | Where-Object { $_.FullName -notmatch 'node_modules' } | Measure-Object | Select-Object -ExpandProperty Count) CSS files
- **Configuration Files**: $(Get-ChildItem -Filter '*.config.*' | Measure-Object | Select-Object -ExpandProperty Count) config files

## 🔍 Recent Changes (Last 24 Hours)
$(Get-ChildItem -Recurse -File | Where-Object { 
    $_.LastWriteTime -gt (Get-Date).AddDays(-1) -and 
    $_.FullName -notmatch '(node_modules|\.git|\.next)' -and
    $_.Extension -match '\.(tsx?|jsx?|css|json)$'
} | Select-Object -First 10 | ForEach-Object { 
    $relativePAth = $_.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    "- $relativePath (Modified: $($_.LastWriteTime.ToString('HH:mm')))"
})

"@

$content | Out-File -FilePath $OutputPath -Encoding utf8
$content | Out-File -FilePath '.ai-context\latest-scan.md' -Encoding utf8
Write-Host "✅ Intelligent project scan completed: $OutputPath" -ForegroundColor Green
