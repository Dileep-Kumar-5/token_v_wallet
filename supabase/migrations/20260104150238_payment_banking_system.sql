-- Location: supabase/migrations/20260104150238_payment_banking_system.sql
-- Schema Analysis: Existing transaction_ledger and user_balances tables
-- Integration Type: NEW_MODULE - Payment and Banking System
-- Dependencies: None (new functionality)

-- 1. TYPES AND ENUMS
CREATE TYPE public.currency_code AS ENUM ('USD', 'INR', 'EURO', 'GBP');
CREATE TYPE public.payment_method_type AS ENUM ('credit_card', 'debit_card', 'bank_account', 'digital_wallet');
CREATE TYPE public.verification_status AS ENUM ('pending', 'under_review', 'verified', 'failed', 'suspended');
CREATE TYPE public.document_type AS ENUM ('bank_statement', 'void_check', 'bank_letter', 'government_id', 'proof_of_address');
CREATE TYPE public.developer_role AS ENUM ('super_admin', 'admin', 'support');

-- 2. CORE TABLES

-- User profiles (if not already exists, create intermediary table)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    country_code TEXT DEFAULT 'US',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Currency Configuration (managed by developers)
CREATE TABLE public.currency_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    currency_code public.currency_code NOT NULL,
    country_code TEXT NOT NULL,
    exchange_rate_to_usd DECIMAL(10, 6) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    min_purchase_amount DECIMAL(10, 2) DEFAULT 10.00,
    max_purchase_amount DECIMAL(10, 2) DEFAULT 10000.00,
    processing_fee_percentage DECIMAL(5, 2) DEFAULT 2.50,
    updated_by UUID REFERENCES public.user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(currency_code, country_code)
);

-- Payment Methods
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    method_type public.payment_method_type NOT NULL,
    currency_code public.currency_code NOT NULL,
    
    -- Card details (masked)
    card_last_four TEXT,
    card_brand TEXT,
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    
    -- Bank account details (masked)
    bank_name TEXT,
    account_last_four TEXT,
    routing_number TEXT,
    
    -- Digital wallet
    wallet_provider TEXT,
    wallet_email TEXT,
    
    -- Status and verification
    verification_status public.verification_status DEFAULT 'pending',
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Security
    payment_token TEXT NOT NULL, -- Tokenized payment data
    fingerprint TEXT, -- Device fingerprint
    
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Bank Accounts for Payouts
CREATE TABLE public.bank_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Bank details
    account_holder_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    account_number_encrypted TEXT NOT NULL, -- Encrypted
    routing_code TEXT NOT NULL, -- SWIFT/IFSC/Routing number
    account_type TEXT DEFAULT 'checking',
    country_code TEXT NOT NULL,
    currency_code public.currency_code NOT NULL,
    
    -- Address verification
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT NOT NULL,
    
    -- Verification
    verification_status public.verification_status DEFAULT 'pending',
    verification_method TEXT DEFAULT 'micro_deposit',
    micro_deposit_amount1 DECIMAL(10, 2),
    micro_deposit_amount2 DECIMAL(10, 2),
    micro_deposit_attempts INTEGER DEFAULT 0,
    verification_deadline TIMESTAMPTZ,
    
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Verification Documents
CREATE TABLE public.verification_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    bank_account_id UUID REFERENCES public.bank_accounts(id) ON DELETE CASCADE,
    
    document_type public.document_type NOT NULL,
    document_url TEXT NOT NULL, -- Secure storage URL
    file_name TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    
    -- AI-powered verification
    auto_verified BOOLEAN DEFAULT false,
    confidence_score DECIMAL(5, 2),
    extracted_data JSONB DEFAULT '{}',
    
    review_status public.verification_status DEFAULT 'pending',
    reviewed_by UUID REFERENCES public.user_profiles(id),
    review_notes TEXT,
    reviewed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Purchase Transactions
CREATE TABLE public.purchase_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    payment_method_id UUID NOT NULL REFERENCES public.payment_methods(id),
    
    -- Transaction details
    amount DECIMAL(10, 2) NOT NULL,
    currency_code public.currency_code NOT NULL,
    token_amount DECIMAL(10, 4) NOT NULL, -- Credits purchased
    exchange_rate DECIMAL(10, 6) NOT NULL,
    processing_fee DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    
    -- Payment gateway
    gateway_transaction_id TEXT,
    gateway_status TEXT,
    
    transaction_status public.transaction_status DEFAULT 'pending',
    completed_at TIMESTAMPTZ,
    
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Payout Transactions
CREATE TABLE public.payout_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    bank_account_id UUID NOT NULL REFERENCES public.bank_accounts(id),
    
    -- Payout details
    amount DECIMAL(10, 2) NOT NULL,
    currency_code public.currency_code NOT NULL,
    token_amount DECIMAL(10, 4) NOT NULL, -- Credits withdrawn
    exchange_rate DECIMAL(10, 6) NOT NULL,
    processing_fee DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    
    -- Payment gateway
    gateway_payout_id TEXT,
    gateway_status TEXT,
    
    transaction_status public.transaction_status DEFAULT 'pending',
    completed_at TIMESTAMPTZ,
    
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Developer Admin System
CREATE TABLE public.developer_admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    developer_role public.developer_role NOT NULL DEFAULT 'support',
    
    -- Permissions
    can_manage_currencies BOOLEAN DEFAULT false,
    can_manage_countries BOOLEAN DEFAULT false,
    can_approve_verifications BOOLEAN DEFAULT false,
    can_manage_admins BOOLEAN DEFAULT false,
    
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMPTZ,
    created_by UUID REFERENCES public.user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Audit Log for Developer Actions
CREATE TABLE public.developer_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES public.developer_admins(id),
    action_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. INDEXES
CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_status ON public.payment_methods(verification_status);
CREATE INDEX idx_bank_accounts_user_id ON public.bank_accounts(user_id);
CREATE INDEX idx_bank_accounts_status ON public.bank_accounts(verification_status);
CREATE INDEX idx_verification_documents_user_id ON public.verification_documents(user_id);
CREATE INDEX idx_verification_documents_bank_account ON public.verification_documents(bank_account_id);
CREATE INDEX idx_purchase_transactions_user_id ON public.purchase_transactions(user_id);
CREATE INDEX idx_payout_transactions_user_id ON public.payout_transactions(user_id);
CREATE INDEX idx_currency_configurations_active ON public.currency_configurations(is_active);
CREATE INDEX idx_developer_admins_user_id ON public.developer_admins(user_id);

-- 4. RLS SETUP
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currency_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.developer_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.developer_audit_log ENABLE ROW LEVEL SECURITY;

-- 5. FUNCTIONS (BEFORE RLS POLICIES)

-- Check if user is a developer admin
CREATE OR REPLACE FUNCTION public.is_developer_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.developer_admins da
    WHERE da.user_id = auth.uid() 
    AND da.is_active = true
)
$$;

-- 6. RLS POLICIES

-- Pattern 1: Core user table
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Currency configurations: Public read, admin write
CREATE POLICY "public_read_currency_configurations"
ON public.currency_configurations
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admins_manage_currency_configurations"
ON public.currency_configurations
FOR ALL
TO authenticated
USING (public.is_developer_admin())
WITH CHECK (public.is_developer_admin());

-- Pattern 2: Simple user ownership for payment methods
CREATE POLICY "users_manage_own_payment_methods"
ON public.payment_methods
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for bank accounts
CREATE POLICY "users_manage_own_bank_accounts"
ON public.bank_accounts
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Verification documents: User + Admin access
CREATE POLICY "users_manage_own_verification_documents"
ON public.verification_documents
FOR ALL
TO authenticated
USING (user_id = auth.uid() OR public.is_developer_admin())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Purchase transactions
CREATE POLICY "users_view_own_purchase_transactions"
ON public.purchase_transactions
FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR public.is_developer_admin());

-- Pattern 2: Payout transactions
CREATE POLICY "users_view_own_payout_transactions"
ON public.payout_transactions
FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR public.is_developer_admin());

-- Developer admins: Self-management + super admin full access
CREATE POLICY "admins_view_developer_admins"
ON public.developer_admins
FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR public.is_developer_admin());

CREATE POLICY "super_admins_manage_developer_admins"
ON public.developer_admins
FOR ALL
TO authenticated
USING (
    user_id = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.developer_admins da 
        WHERE da.user_id = auth.uid() 
        AND da.developer_role = 'super_admin'
        AND da.can_manage_admins = true
    )
);

-- Audit log: Admins read-only
CREATE POLICY "admins_read_audit_log"
ON public.developer_audit_log
FOR SELECT
TO authenticated
USING (public.is_developer_admin());

-- 7. TRIGGERS

-- Auto-update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_currency_configurations_updated_at
    BEFORE UPDATE ON public.currency_configurations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_payment_methods_updated_at
    BEFORE UPDATE ON public.payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_bank_accounts_updated_at
    BEFORE UPDATE ON public.bank_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 8. UTILITY FUNCTIONS

-- Get active currency configuration
CREATE OR REPLACE FUNCTION public.get_active_currency_config(p_currency public.currency_code, p_country TEXT)
RETURNS TABLE(
    exchange_rate DECIMAL(10, 6),
    min_amount DECIMAL(10, 2),
    max_amount DECIMAL(10, 2),
    fee_percentage DECIMAL(5, 2)
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    exchange_rate_to_usd,
    min_purchase_amount,
    max_purchase_amount,
    processing_fee_percentage
FROM public.currency_configurations
WHERE currency_code = p_currency 
AND country_code = p_country 
AND is_active = true
LIMIT 1
$$;