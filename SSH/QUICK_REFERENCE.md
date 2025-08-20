# SSH & WordPress REST API - Quick Reference

## 🔑 Essential Credentials
- **Server Cendol**: `162.243.15.7`
- **Server Bessie**: `68.183.24.139`
- **SSH Private Key**: `C:\Users\user\.ssh\gridpane_rsa`
- **SSH Public Key**: `C:\Users\user\.ssh\gridpane_rsa.pub`
- **WordPress User**: `Editorial Team`
- **App Password**: `WPmdQdvx28yjpWguZGWPZKey`

## ⚡ Quick Commands

### SSH Connection
```bash
# Cendol server
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7

# Bessie server  
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@68.183.24.139
```

### WordPress CLI
```bash
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'cd /var/www/staging.stocktiming.com/htdocs && sudo -u stocktiming11482 wp user list'
```

### REST API
```bash
curl -u "Editorial Team:WPmdQdvx28yjpWguZGWPZKey" "https://staging.stocktiming.com/wp-json/wp/v2/posts?per_page=5"
```

### PowerShell Scripts
```powershell
.\SSH\wp-cli-commands.ps1 -Command users
.\SSH\rest-api-test-fixed.ps1
```

## 📁 File Locations
- **SSH Keys**: `C:\Users\user\.ssh\`
- **Scripts**: `C:\Users\user\alphadev2\SSH\`
- **Sites Database**: `C:\Users\user\alphadev2\SSH\gridpane-sites.csv`
- **Documentation**: `C:\Users\user\alphadev2\SSH\COMPLETE_SETUP_DOCUMENTATION.md`

## 🌐 Server Summary
- **Cendol** (162.243.15.7): 20 sites
- **Bessie** (68.183.24.139): 34 sites  
- **Legal-may25** (138.197.11.181): 21 sites
- **Kampung-may25** (162.243.4.151): 1 site
- **Total**: 76 active sites across 4 servers