-- Location: supabase/migrations/20260104150238_payment_and_payout_system.sql
-- Schema Analysis: Existing tables - transaction_ledger, user_balances
-- Integration Type: addition (NEW_MODULE - Payment & Payout System)
-- Dependencies: References transaction_ledger for payment tracking

-- 1. Types - Currency and payment-related enums
CREATE TYPE public.currency_code AS ENUM ('USD', 'INR', 'EUR', 'GBP');
CREATE TYPE public.payment_method_type AS ENUM ('credit_card', 'debit_card', 'bank_account');
CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'cancelled');
CREATE TYPE public.payout_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'cancelled');
CREATE TYPE public.verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');

-- 2. Core Tables - Currency configurations
CREATE TABLE public.currency_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    currency_code public.currency_code NOT NULL UNIQUE,
    exchange_rate_to_usd DECIMAL(10, 6) NOT NULL,
    symbol TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    min_transaction_amount DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    max_transaction_amount DECIMAL(10, 2) NOT NULL DEFAULT 10000.00,
    conversion_fee_percentage DECIMAL(5, 2) NOT NULL DEFAULT 2.50,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Country/region settings
CREATE TABLE public.country_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code TEXT NOT NULL UNIQUE,
    country_name TEXT NOT NULL,
    default_currency public.currency_code NOT NULL,
    is_active BOOLEAN DEFAULT true,
    regulatory_approval_status public.verification_status DEFAULT 'pending'::public.verification_status,
    supported_payment_methods public.payment_method_type[] DEFAULT ARRAY['credit_card'::public.payment_method_type],
    banking_integration_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User payment methods
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    method_type public.payment_method_type NOT NULL,
    card_last_four TEXT,
    card_brand TEXT,
    card_exp_month INT,
    card_exp_year INT,
    bank_account_last_four TEXT,
    bank_name TEXT,
    stripe_payment_method_id TEXT UNIQUE,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_methods_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- User bank accounts for payouts
CREATE TABLE public.bank_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    account_holder_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    account_number_last_four TEXT NOT NULL,
    routing_number TEXT,
    swift_code TEXT,
    iban TEXT,
    account_currency public.currency_code NOT NULL,
    country_code TEXT NOT NULL,
    verification_status public.verification_status DEFAULT 'unverified'::public.verification_status,
    verification_documents JSONB,
    stripe_bank_account_id TEXT UNIQUE,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bank_accounts_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Payment transactions (token purchases)
CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency public.currency_code NOT NULL,
    tokens_purchased DECIMAL(10, 4) NOT NULL,
    conversion_rate DECIMAL(10, 6) NOT NULL,
    fee_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    stripe_payment_intent_id TEXT UNIQUE,
    ledger_transaction_id UUID,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_transactions_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_payment_transactions_method FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_transactions_ledger FOREIGN KEY (ledger_transaction_id) REFERENCES public.transaction_ledger(id) ON DELETE SET NULL
);

-- Payout transactions
CREATE TABLE public.payout_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    bank_account_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency public.currency_code NOT NULL,
    tokens_withdrawn DECIMAL(10, 4) NOT NULL,
    conversion_rate DECIMAL(10, 6) NOT NULL,
    fee_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    net_amount DECIMAL(10, 2) NOT NULL,
    payout_status public.payout_status DEFAULT 'pending'::public.payout_status,
    stripe_payout_id TEXT UNIQUE,
    ledger_transaction_id UUID,
    estimated_arrival_date TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payout_transactions_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_payout_transactions_bank FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id) ON DELETE RESTRICT,
    CONSTRAINT fk_payout_transactions_ledger FOREIGN KEY (ledger_transaction_id) REFERENCES public.transaction_ledger(id) ON DELETE SET NULL
);

-- 3. Essential Indexes
CREATE INDEX idx_currency_settings_code ON public.currency_settings(currency_code);
CREATE INDEX idx_country_settings_code ON public.country_settings(country_code);
CREATE INDEX idx_payment_methods_user ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_stripe ON public.payment_methods(stripe_payment_method_id);
CREATE INDEX idx_bank_accounts_user ON public.bank_accounts(user_id);
CREATE INDEX idx_bank_accounts_verification ON public.bank_accounts(verification_status);
CREATE INDEX idx_payment_transactions_user ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(payment_status);
CREATE INDEX idx_payout_transactions_user ON public.payout_transactions(user_id);
CREATE INDEX idx_payout_transactions_status ON public.payout_transactions(payout_status);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 5. Enable RLS
ALTER TABLE public.currency_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.country_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies
-- Currency settings - admin only for modifications, public read
CREATE POLICY "public_can_read_currency_settings"
ON public.currency_settings
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_currency_settings"
ON public.currency_settings
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin' 
             OR au.raw_app_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin' 
             OR au.raw_app_meta_data->>'role' = 'admin')
    )
);

-- Country settings - admin only for modifications, public read
CREATE POLICY "public_can_read_country_settings"
ON public.country_settings
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_country_settings"
ON public.country_settings
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin' 
             OR au.raw_app_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin' 
             OR au.raw_app_meta_data->>'role' = 'admin')
    )
);

-- Payment methods - users manage own
CREATE POLICY "users_manage_own_payment_methods"
ON public.payment_methods
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Bank accounts - users manage own
CREATE POLICY "users_manage_own_bank_accounts"
ON public.bank_accounts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Payment transactions - users manage own
CREATE POLICY "users_manage_own_payment_transactions"
ON public.payment_transactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Payout transactions - users manage own
CREATE POLICY "users_manage_own_payout_transactions"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER update_currency_settings_timestamp
    BEFORE UPDATE ON public.currency_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_country_settings_timestamp
    BEFORE UPDATE ON public.country_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_payment_methods_timestamp
    BEFORE UPDATE ON public.payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_bank_accounts_timestamp
    BEFORE UPDATE ON public.bank_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_payment_transactions_timestamp
    BEFORE UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_payout_transactions_timestamp
    BEFORE UPDATE ON public.payout_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- 8. Mock Data
DO $$
BEGIN
    -- Insert default currency settings
    INSERT INTO public.currency_settings (currency_code, exchange_rate_to_usd, symbol, is_active, min_transaction_amount, max_transaction_amount, conversion_fee_percentage)
    VALUES
        ('USD'::public.currency_code, 1.000000, '$', true, 1.00, 10000.00, 2.50),
        ('EUR'::public.currency_code, 0.920000, '€', true, 1.00, 10000.00, 2.50),
        ('GBP'::public.currency_code, 0.790000, '£', true, 1.00, 10000.00, 2.50),
        ('INR'::public.currency_code, 83.150000, '₹', true, 100.00, 1000000.00, 2.50);

    -- Insert default country settings
    INSERT INTO public.country_settings (country_code, country_name, default_currency, is_active, regulatory_approval_status, supported_payment_methods, banking_integration_active)
    VALUES
        ('US', 'United States', 'USD'::public.currency_code, true, 'verified'::public.verification_status, ARRAY['credit_card'::public.payment_method_type, 'debit_card'::public.payment_method_type, 'bank_account'::public.payment_method_type], true),
        ('GB', 'United Kingdom', 'GBP'::public.currency_code, true, 'verified'::public.verification_status, ARRAY['credit_card'::public.payment_method_type, 'debit_card'::public.payment_method_type, 'bank_account'::public.payment_method_type], true),
        ('DE', 'Germany', 'EUR'::public.currency_code, true, 'pending'::public.verification_status, ARRAY['credit_card'::public.payment_method_type, 'debit_card'::public.payment_method_type], false),
        ('IN', 'India', 'INR'::public.currency_code, true, 'pending'::public.verification_status, ARRAY['credit_card'::public.payment_method_type, 'debit_card'::public.payment_method_type], false);
END $$;