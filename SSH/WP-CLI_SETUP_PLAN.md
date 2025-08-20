# WordPress CLI Setup Plan for GridPane Server

## End Goal
Enable programmatic control of WordPress sites on GridPane server from Windows terminal using WP-CLI to create application passwords for secure REST API access.

## Prerequisites
- GridPane server with staging.stocktiming.com
- Windows terminal/PowerShell access
- GridPane dashboard access

## Step-by-Step Execution Plan

### Phase 1: SSH Key Setup
1. **Generate SSH Keys on Windows**
   ```powershell
   # Generate SSH key pair
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   # Default location: C:\Users\user\.ssh\id_rsa
   ```

2. **Get Public Key**
   ```powershell
   # Copy public key to clipboard
   Get-Content C:\Users\user\.ssh\id_rsa.pub | Set-Clipboard
   ```

3. **Add SSH Key to GridPane**
   - Login to GridPane Dashboard
   - Go to Servers → Your Server → SSH Keys tab
   - Paste public key and click "Add Key"

### Phase 2: SSH Connection Setup
4. **Enable System User SSH Access**
   ```bash
   # Connect as root first
   ssh root@YOUR_SERVER_IP
   
   # Enable SSH for system user
   gp user YOUR_SYSTEM_USERNAME -ssh-access true
   
   # Find system username
   gp sites list
   ```

5. **Test SSH Connections**
   ```bash
   # Test root connection
   ssh root@YOUR_SERVER_IP
   
   # Test system user connection
   ssh SYSTEM_USERNAME@YOUR_SERVER_IP
   ```

### Phase 3: WP-CLI Application Password Creation
6. **Create Application Password**
   ```bash
   # Using GP WP-CLI (recommended)
   gp wp staging.stocktiming.com user application-password create ADMIN_USERNAME "RESTAPI"
   
   # List users first if needed
   gp wp staging.stocktiming.com user list
   ```

7. **Test Application Password**
   ```powershell
   # Test REST API access from Windows
   curl -u "admin:PASSWORD_HERE" https://staging.stocktiming.com/wp-json/wp/v2/posts
   ```

## Quick Reference Commands

### SSH Key Management
- Generate key: `ssh-keygen -t rsa -b 4096 -C "email@domain.com"`
- View public key: `cat ~/.ssh/id_rsa.pub`
- Test connection: `ssh -v root@SERVER_IP`

### GridPane WP-CLI Commands
- List sites: `gp sites list`
- List users: `gp wp DOMAIN user list`
- Create app password: `gp wp DOMAIN user application-password create USERNAME "NAME"`
- List app passwords: `gp wp DOMAIN user application-password list USERNAME`
- Delete app password: `gp wp DOMAIN user application-password delete USERNAME UUID`

### WordPress Application Password Management
- Create: `gp wp staging.stocktiming.com user application-password create admin "RESTAPI"`
- List: `gp wp staging.stocktiming.com user application-password list admin`
- Delete: `gp wp staging.stocktiming.com user application-password delete admin UUID`

## Expected Outcomes
1. Secure SSH access from Windows to GridPane server
2. Ability to run WP-CLI commands remotely
3. Programmatically created WordPress application passwords
4. Secure REST API authentication for automated workflows

## Security Notes
- SSH keys provide secure, passwordless authentication
- Application passwords are site-specific and can be revoked
- No need to use main WordPress admin password for API access
- All commands logged and traceable through GridPane

## Troubleshooting
- Permission issues: Check system user ownership with `ls -la`
- SSH issues: Use `ssh -v` for verbose debugging
- WP-CLI issues: Ensure you're in correct directory or use GP WP-CLI
- Fix permissions: `gp fix-perms DOMAIN`