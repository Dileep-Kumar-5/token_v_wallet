# Stripe Payment Integration Setup Guide

## Overview
This guide provides step-by-step instructions for setting up Stripe payment processing in your Token V Wallet application with multi-currency support (USD, INR, EURO, GBP).

## Prerequisites
1. Stripe account (sign up at https://stripe.com)
2. Supabase project with CLI installed
3. Flutter development environment

## Step 1: Configure Stripe Environment Variables

### 1.1 Get Stripe API Keys
1. Log in to your Stripe Dashboard (https://dashboard.stripe.com)
2. Navigate to **Developers > API keys**
3. Copy your **Publishable key** (starts with `pk_test_` for test mode)
4. Copy your **Secret key** (starts with `sk_test_` for test mode)

### 1.2 Set Flutter Environment Variable
Add to your build/run configuration:
```bash
--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

Or create `env.json` in project root (NOT tracked in git):
```json
{
  "STRIPE_PUBLISHABLE_KEY": "pk_test_your_key_here"
}
```

### 1.3 Set Supabase Environment Variables
```bash
# Set Stripe secret key in Supabase
supabase secrets set STRIPE_SECRET_KEY=sk_test_your_secret_key_here
```

## Step 2: Deploy Supabase Edge Functions

### 2.1 Deploy Create Payment Intent Function
```bash
supabase functions deploy create-payment-intent
```

### 2.2 Deploy Verify Payment Function
```bash
supabase functions deploy verify-payment
```

### 2.3 Verify Deployment
```bash
supabase functions list
```

## Step 3: Configure Currency Rates

Insert or update currency configurations in your database:

```sql
-- Insert currency configurations
INSERT INTO currency_configurations (currency_code, exchange_rate_to_usd, processing_fee_percentage, min_purchase_amount, max_purchase_amount, is_active, country_code)
VALUES 
  ('USD', 1.0, 2.9, 1.0, 10000.0, true, 'US'),
  ('INR', 83.0, 3.5, 50.0, 500000.0, true, 'IN'),
  ('EURO', 0.92, 3.2, 1.0, 10000.0, true, 'EU'),
  ('GBP', 0.79, 3.0, 1.0, 10000.0, true, 'GB')
ON CONFLICT (currency_code) 
DO UPDATE SET 
  exchange_rate_to_usd = EXCLUDED.exchange_rate_to_usd,
  processing_fee_percentage = EXCLUDED.processing_fee_percentage,
  is_active = EXCLUDED.is_active;
```

## Step 4: Test Payment Flow

### 4.1 Use Stripe Test Cards
- **Success**: 4242 4242 4242 4242
- **Declined**: 4000 0000 0000 9995
- **3D Secure**: 4000 0000 0000 3220

### 4.2 Test Parameters
- Use any future expiration date (e.g., 12/34)
- Use any 3-digit CVC
- Use any 5-digit ZIP code

### 4.3 Verify Transaction Flow
1. Navigate to checkout screen in app
2. Enter billing information
3. Enter test card details using CardField
4. Submit payment
5. Verify transaction status in database
6. Check wallet balance is updated

## Step 5: Production Deployment

### 5.1 Switch to Live Mode
1. Get live API keys from Stripe Dashboard
2. Update environment variables with live keys:
```bash
# Flutter
--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key_here

# Supabase
supabase secrets set STRIPE_SECRET_KEY=sk_live_your_secret_key_here
```

### 5.2 Enable Payment Methods
In Stripe Dashboard, enable payment methods for each currency:
- Cards (Visa, Mastercard, Amex)
- Digital wallets (Apple Pay, Google Pay)
- Local payment methods per region

### 5.3 Configure Webhooks (Optional)
For production, set up webhooks for payment status updates:
1. Go to Stripe Dashboard > Developers > Webhooks
2. Add endpoint: `https://your-project.supabase.co/functions/v1/stripe-webhook`
3. Select events: `payment_intent.succeeded`, `payment_intent.failed`

## Security Considerations

1. **Never commit API keys to version control**
2. **Use environment variables for all sensitive data**
3. **Enable Stripe Radar for fraud detection**
4. **Implement proper RLS policies in Supabase**
5. **Use HTTPS only for all API calls**

## Troubleshooting

### Common Issues

**Issue**: "Stripe initialization failed"
- **Solution**: Verify STRIPE_PUBLISHABLE_KEY is set correctly

**Issue**: "Payment intent creation failed"
- **Solution**: Check Supabase Edge Function logs and verify STRIPE_SECRET_KEY

**Issue**: "Transaction not updating"
- **Solution**: Verify RLS policies allow authenticated users to update their transactions

**Issue**: "Currency not supported"
- **Solution**: Ensure currency is added to currency_configurations table

## Support Resources

- Stripe Documentation: https://stripe.com/docs
- Supabase Edge Functions: https://supabase.com/docs/guides/functions
- Flutter Stripe Plugin: https://pub.dev/packages/flutter_stripe

## Testing Checklist

- [ ] Environment variables configured
- [ ] Edge functions deployed
- [ ] Currency configurations inserted
- [ ] Test payment successful
- [ ] Transaction recorded in database
- [ ] Wallet balance updated
- [ ] Payment receipt generated
- [ ] Multi-currency support verified
- [ ] Error handling tested
- [ ] Production keys configured (for live deployment)