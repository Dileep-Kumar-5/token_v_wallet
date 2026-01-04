-- Location: supabase/migrations/20260104131717_immutable_transaction_ledger.sql
-- Module: Transaction Ledger System
-- Schema Analysis: Fresh database - no existing tables
-- Integration Type: NEW_MODULE - Complete ledger system
-- Dependencies: None (fresh start)

-- 1. Types - Transaction types and status
CREATE TYPE public.transaction_type AS ENUM ('credit', 'debit', 'adjustment', 'refund', 'fee');
CREATE TYPE public.transaction_status AS ENUM ('pending', 'completed', 'failed', 'reversed');

-- 2. Immutable Ledger Table - Core transaction log
CREATE TABLE public.transaction_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    transaction_type public.transaction_type NOT NULL,
    amount DECIMAL(19,4) NOT NULL CHECK (amount != 0),
    running_balance DECIMAL(19,4) NOT NULL,
    reference_id TEXT,
    description TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::JSONB,
    transaction_status public.transaction_status DEFAULT 'completed'::public.transaction_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID,
    
    -- Immutability enforcement
    CONSTRAINT no_negative_balance CHECK (running_balance >= 0),
    CONSTRAINT valid_amount CHECK (
        (transaction_type = 'credit' AND amount > 0) OR
        (transaction_type IN ('debit', 'fee') AND amount < 0) OR
        (transaction_type IN ('adjustment', 'refund'))
    )
);

-- Prevent updates and deletes to maintain immutability
CREATE OR REPLACE FUNCTION public.prevent_ledger_modifications()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    RAISE EXCEPTION 'Transaction ledger is immutable. Cannot modify or delete records.';
    RETURN NULL;
END;
$func$;

CREATE TRIGGER prevent_update_transaction_ledger
BEFORE UPDATE ON public.transaction_ledger
FOR EACH ROW EXECUTE FUNCTION public.prevent_ledger_modifications();

CREATE TRIGGER prevent_delete_transaction_ledger
BEFORE DELETE ON public.transaction_ledger
FOR EACH ROW EXECUTE FUNCTION public.prevent_ledger_modifications();

-- 3. Balance Calculation View - Derived from ledger only
CREATE VIEW public.user_balances AS
SELECT 
    user_id,
    COALESCE(MAX(running_balance), 0.0000) AS current_balance,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_credits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) AS total_debits,
    MAX(created_at) AS last_transaction_date
FROM public.transaction_ledger
WHERE transaction_status = 'completed'
GROUP BY user_id;

-- 4. Function to Calculate Next Balance
CREATE OR REPLACE FUNCTION public.calculate_next_balance(
    p_user_id UUID,
    p_amount DECIMAL(19,4)
)
RETURNS DECIMAL(19,4)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
DECLARE
    v_current_balance DECIMAL(19,4) := 0.0000; -- Initialize to 0 for new users
    v_new_balance DECIMAL(19,4);
BEGIN
    -- Get current balance from latest ledger entry
    SELECT COALESCE(running_balance, 0.0000)
    INTO v_current_balance
    FROM public.transaction_ledger
    WHERE user_id = p_user_id
        AND transaction_status = 'completed'
    ORDER BY created_at DESC, id DESC
    LIMIT 1;
    
    -- If no rows found, v_current_balance remains 0.0000 (initialized value)
    -- Calculate new balance
    v_new_balance := COALESCE(v_current_balance, 0.0000) + p_amount;
    
    -- Ensure non-negative balance
    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'Insufficient balance. Current: %, Requested: %', v_current_balance, p_amount;
    END IF;
    
    RETURN v_new_balance;
END;
$func$;

-- 5. Function to Add Transaction with Balance Calculation
CREATE OR REPLACE FUNCTION public.add_transaction(
    p_user_id UUID,
    p_transaction_type public.transaction_type,
    p_amount DECIMAL(19,4),
    p_description TEXT,
    p_reference_id TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::JSONB,
    p_created_by UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_new_balance DECIMAL(19,4);
    v_transaction_id UUID;
    v_signed_amount DECIMAL(19,4);
BEGIN
    -- Normalize amount based on transaction type
    v_signed_amount := CASE
        WHEN p_transaction_type = 'credit' THEN ABS(p_amount)
        WHEN p_transaction_type IN ('debit', 'fee') THEN -ABS(p_amount)
        ELSE p_amount
    END;
    
    -- Calculate new balance
    v_new_balance := public.calculate_next_balance(p_user_id, v_signed_amount);
    
    -- Insert transaction
    INSERT INTO public.transaction_ledger (
        user_id,
        transaction_type,
        amount,
        running_balance,
        reference_id,
        description,
        metadata,
        transaction_status,
        created_by
    ) VALUES (
        p_user_id,
        p_transaction_type,
        v_signed_amount,
        v_new_balance,
        p_reference_id,
        p_description,
        p_metadata,
        'completed',
        p_created_by
    )
    RETURNING id INTO v_transaction_id;
    
    RETURN v_transaction_id;
END;
$func$;

-- 6. Function to Get Transaction History with Balance
CREATE OR REPLACE FUNCTION public.get_transaction_history(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    transaction_type TEXT,
    amount DECIMAL(19,4),
    running_balance DECIMAL(19,4),
    description TEXT,
    reference_id TEXT,
    transaction_status TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
BEGIN
    RETURN QUERY
    SELECT 
        tl.id,
        tl.transaction_type::TEXT,
        tl.amount,
        tl.running_balance,
        tl.description,
        tl.reference_id,
        tl.transaction_status::TEXT,
        tl.created_at
    FROM public.transaction_ledger tl
    WHERE tl.user_id = p_user_id
    ORDER BY tl.created_at DESC, tl.id DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$func$;

-- 7. Essential Indexes for Performance
CREATE INDEX idx_transaction_ledger_user_id ON public.transaction_ledger(user_id);
CREATE INDEX idx_transaction_ledger_created_at ON public.transaction_ledger(created_at DESC);
CREATE INDEX idx_transaction_ledger_user_status ON public.transaction_ledger(user_id, transaction_status, created_at DESC);
CREATE INDEX idx_transaction_ledger_reference ON public.transaction_ledger(reference_id) WHERE reference_id IS NOT NULL;

-- 8. RLS Setup
ALTER TABLE public.transaction_ledger ENABLE ROW LEVEL SECURITY;

-- Public read access for demonstration (adjust based on auth requirements)
CREATE POLICY "public_read_ledger"
ON public.transaction_ledger
FOR SELECT
TO public
USING (true);

-- Only functions can insert (enforces workflow pattern)
CREATE POLICY "function_insert_only"
ON public.transaction_ledger
FOR INSERT
TO authenticated
WITH CHECK (false);

-- 9. Mock Data - Sample transactions
DO $$
DECLARE
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
BEGIN
    -- User 1 transactions
    PERFORM public.add_transaction(
        user1_id,
        'credit',
        1000.0000,
        'Initial deposit',
        'REF-001',
        '{"source": "bank_transfer"}'::JSONB
    );
    
    PERFORM public.add_transaction(
        user1_id,
        'debit',
        150.5000,
        'Purchase at Store A',
        'TXN-001',
        '{"merchant": "Store A", "category": "shopping"}'::JSONB
    );
    
    PERFORM public.add_transaction(
        user1_id,
        'credit',
        500.0000,
        'Salary payment',
        'SAL-001',
        '{"type": "salary", "period": "January 2026"}'::JSONB
    );
    
    PERFORM public.add_transaction(
        user1_id,
        'fee',
        5.0000,
        'Monthly maintenance fee',
        'FEE-001',
        '{"type": "maintenance"}'::JSONB
    );
    
    -- User 2 transactions
    PERFORM public.add_transaction(
        user2_id,
        'credit',
        2500.0000,
        'Initial deposit',
        'REF-002',
        '{"source": "cash"}'::JSONB
    );
    
    PERFORM public.add_transaction(
        user2_id,
        'debit',
        300.0000,
        'Online purchase',
        'TXN-002',
        '{"merchant": "Online Store", "category": "electronics"}'::JSONB
    );
    
    PERFORM public.add_transaction(
        user2_id,
        'refund',
        50.0000,
        'Refund for returned item',
        'REF-003',
        '{"original_txn": "TXN-002"}'::JSONB
    );
END $$;

-- 10. Audit Function - Verify balance integrity
CREATE OR REPLACE FUNCTION public.audit_balance_integrity()
RETURNS TABLE (
    user_id UUID,
    calculated_balance DECIMAL(19,4),
    ledger_balance DECIMAL(19,4),
    difference DECIMAL(19,4),
    is_valid BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    RETURN QUERY
    WITH balance_check AS (
        SELECT 
            tl.user_id,
            SUM(tl.amount) AS calculated_balance,
            MAX(tl.running_balance) AS ledger_balance
        FROM public.transaction_ledger tl
        WHERE tl.transaction_status = 'completed'
        GROUP BY tl.user_id
    )
    SELECT 
        bc.user_id,
        bc.calculated_balance,
        bc.ledger_balance,
        bc.ledger_balance - bc.calculated_balance AS difference,
        (bc.ledger_balance - bc.calculated_balance) = 0.0000 AS is_valid
    FROM balance_check bc;
END;
$func$;

COMMENT ON TABLE public.transaction_ledger IS 'Immutable ledger for all credit movements. Balance is calculated from ledger entries only.';
COMMENT ON FUNCTION public.add_transaction IS 'Workflow function to add transactions with automatic balance calculation. Only way to modify ledger.';
COMMENT ON VIEW public.user_balances IS 'Derived balance view - calculated from ledger entries, not stored as editable field.';