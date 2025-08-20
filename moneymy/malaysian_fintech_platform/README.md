# Malaysian Financial Products Dataset

## Overview
This comprehensive dataset contains **127 realistic financial products** from **15 major Malaysian banks**, designed for building a financial comparison platform similar to RinggitPlus and iMoney.

## Dataset Contents

### Product Categories
- **Credit Cards**: 30 products (7 categories: Cashback, Travel, Rewards, Premium, Islamic, Student, Business)
- **Personal Loans**: 24 products (5 types: Conventional, Islamic, Salary, Collateral, Digital)
- **Home Loans**: 18 products (Fixed Rate, Variable Rate, Islamic, First-time Buyer programs)
- **Fixed Deposits**: 20 products (Regular, Islamic, Premium, Senior Citizen, Foreign Currency)
- **Savings Accounts**: 20 products (Basic, Premium, Islamic, Kids, Senior)
- **Car Loans**: 15 products (New Car, Used Car, Islamic, Refinancing, Commercial Vehicle)

### Banks Covered (15 Major Malaysian Banks)
1. Maybank - Malaysia's largest bank
2. CIMB Bank - Leading commercial bank
3. Public Bank - Major retail bank
4. RHB Bank - Established commercial bank
5. Hong Leong Bank - Comprehensive banking services
6. AmBank - Full-service commercial bank
7. Affin Bank - Malaysian commercial bank
8. Alliance Bank - Innovative banking solutions
9. OCBC Bank - Singapore-based regional bank
10. UOB Malaysia - United Overseas Bank
11. Standard Chartered Malaysia - International bank
12. HSBC Malaysia - Global banking presence
13. Bank Islam Malaysia - Leading Islamic bank
14. MUAMALAT Bank - Shariah-compliant banking
15. Bank Rakyat - Community-focused banking

## File Structure

### JSON Files (8 files)
- `credit_cards.json` - 30 credit card products
- `personal_loans.json` - 24 personal loan products
- `home_loans.json` - 18 home loan products
- `fixed_deposits.json` - 20 fixed deposit products
- `savings_accounts.json` - 20 savings account products
- `car_loans.json` - 15 car loan products
- `all_financial_products.json` - Combined dataset with all products
- `dataset_summary.json` - Dataset statistics and metadata

### CSV Files (8 files)
- Individual CSV files for each product category
- `all_financial_products.csv` - Master CSV with all products (127 rows, 117 columns)
- `malaysian_banks.csv` - Bank reference data (15 banks with contact details)

## Key Features

### Realistic Malaysian Market Data
- **Interest Rates**: Based on current Malaysian market rates (2024)
- **Fees**: Realistic annual fees, processing fees, and charges in Ringgit Malaysia (RM)
- **Eligibility Criteria**: Age limits, income requirements, citizenship requirements
- **Islamic Banking**: Shariah-compliant products with proper Islamic financing principles
- **Bank Contact Info**: Phone numbers, emails, websites, branch counts

### Comprehensive Product Information
Each product includes:
- Unique product ID and name
- Bank details with logos
- Interest rates and fees
- Features and benefits
- Eligibility requirements
- Contact information
- Promotional offers
- Required documents
- Terms and conditions

### Platform-Ready Features
- **Filtering**: Products can be filtered by bank, type, interest rate, fees
- **Comparison**: Side-by-side comparison capabilities
- **Sorting**: Multiple sort options (rate, fees, popularity)
- **Search**: Searchable product names and features
- **Application**: Ready for loan application form integration

## Usage Examples

### Loading the Data
```python
import json
import pandas as pd

# Load all products
with open('all_financial_products.json', 'r') as f:
    all_products = json.load(f)

# Load specific category
with open('credit_cards.json', 'r') as f:
    credit_cards = json.load(f)

# Load as DataFrame for analysis
df = pd.read_csv('all_financial_products.csv')
```

### Common Queries
```python
# Find all Islamic products
islamic_products = df[df['is_islamic'] == True]

# Credit cards with no annual fee
free_cards = df[(df['category'] == 'credit_cards') & (df['annual_fee'] == 0)]

# Home loans under 4% interest
low_rate_home_loans = df[(df['category'] == 'home_loans') & (df['interest_rate'] < 4.0)]

# Savings accounts with high interest rates
high_yield_savings = df[(df['category'] == 'savings_accounts') & (df['interest_rate'] > 2.5)]
```

### Building Comparison Features
```python
# Compare credit cards by cashback rate
cc_comparison = df[df['category'] == 'credit_cards'][['product_name', 'bank', 'cashback_rate', 'annual_fee']].sort_values('cashback_rate', ascending=False)

# Compare personal loans by interest rate
pl_comparison = df[df['category'] == 'personal_loans'][['product_name', 'bank', 'interest_rate', 'max_amount']].sort_values('interest_rate')
```

## Interest Rate Ranges by Product

### Credit Cards: 15.0% - 18.0% p.a.
- Cashback Cards: Competitive rates with rewards
- Premium Cards: Higher limits, exclusive benefits
- Islamic Cards: Shariah-compliant profit-sharing

### Personal Loans: 2.8% - 8.0% p.a.
- Salary Loans: Lower rates for salaried employees
- Collateral Loans: Secured loan options
- Digital Loans: Fast approval, competitive rates

### Home Loans: 3.3% - 5.6% p.a.
- Fixed Rate: Stable monthly payments
- Variable Rate: Market-linked rates
- Islamic Home Financing: Shariah-compliant options

### Fixed Deposits: 2.5% - 4.2% p.a.
- Regular FD: Standard tenure options
- Premium FD: Higher returns for larger amounts
- Senior Citizen FD: Special rates for seniors

### Savings Accounts: 0.5% - 3.5% p.a.
- Basic Savings: Low minimum balance
- Premium Savings: Higher rates, premium services
- Kids Savings: Educational savings programs

### Car Loans: 2.3% - 6.8% p.a.
- New Car Loans: Competitive rates, full financing
- Used Car Loans: Flexible terms
- Islamic Car Financing: Shariah-compliant options

## Data Quality & Realism

### Market-Accurate Information
- Interest rates reflect current Malaysian banking market (2024)
- Fee structures based on actual bank offerings
- Eligibility criteria aligned with Malaysian banking regulations
- Product features match real-world banking products

### Comprehensive Coverage
- All major Malaysian banks represented
- Full spectrum of retail banking products
- Both conventional and Islamic banking options
- Products suitable for different customer segments

## Application Development Ready

This dataset is designed to support building:
- **Comparison Platforms**: Filter, sort, and compare products
- **Loan Application Systems**: Complete product information for applications
- **Financial Advisory Tools**: Recommend suitable products
- **Rate Tracking Systems**: Monitor and update product rates
- **Customer Portals**: Help customers find the best products

## Technical Specifications

- **Data Format**: JSON and CSV
- **Encoding**: UTF-8
- **Total Records**: 127 financial products
- **Data Fields**: 117+ attributes per product
- **Relationship**: Products linked to bank information
- **Updates**: Dataset timestamp: 2024-01-15

## Next Steps for Platform Development

1. **Database Integration**: Load data into your preferred database
2. **API Development**: Create REST APIs for product queries
3. **Frontend Integration**: Build comparison interfaces
4. **Real-time Updates**: Implement rate monitoring and updates
5. **Application Forms**: Integrate with loan application workflows
6. **Analytics**: Add usage tracking and recommendations

---

**Created**: January 2024  
**Purpose**: Malaysian Fintech Platform Development (RinggitPlus/iMoney model)  
**Total Products**: 127 across 6 categories  
**Banks Covered**: 15 major Malaysian financial institutions  
