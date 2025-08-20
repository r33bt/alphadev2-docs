create a script that can access gridpane api to check acc settings and make changes using the gridpane cli

eg. for now i want to get a list of all sites and their php versions 

create .env with template for credentials

==

Regular Flow for New Site Creation in GridPane UI

url: enter domain namme
server: select server - let me input by name ie lucy, daisy etc
system user: autocreate new user
php version: 
DNS API Integration: cloudflare full
DNS API Key: normally cloudflare websitedn or massiveniche accounts

so input file eg:
domain,server,php,dns api
example.com,lucy,php8.1,websitedn

==

# GridPane Site Management Script

## Objectives
- Create a script to interact with GridPane API/CLI
- Retrieve list of all sites and their PHP versions
- Implement functionality for checking account settings
- Enable making changes via GridPane CLI

## Requirements
- GridPane API credentials
- Environment configuration (.env) for secure credential storage

## Todo
1. Create .env template with required credentials
2. Implement site listing functionality
3. Add PHP version retrieval
4. Add account settings check
5. Implement CLI-based modifications

