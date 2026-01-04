import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Get the authorization token from the request headers
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing Authorization header');
    }

    // Create a Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    const supabase = createClient(supabaseUrl!, supabaseAnonKey!, {
      global: { headers: { Authorization: authHeader } }
    });

    // Create a Stripe client
    const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
    const stripe = new Stripe(stripeKey!, {
      apiVersion: '2023-10-16',
    });

    // Get the request body
    const { clientSecret } = await req.json();
    
    if (!clientSecret) {
      throw new Error('Missing client secret');
    }

    // Extract payment intent ID from client secret
    const paymentIntentId = clientSecret.split('_secret_')[0];

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    // Find transaction by payment intent ID
    const { data: transaction, error: fetchError } = await supabase
      .from('purchase_transactions')
      .select('*')
      .eq('gateway_transaction_id', paymentIntentId)
      .single();

    if (fetchError || !transaction) {
      throw new Error('Transaction not found');
    }

    // Update transaction based on payment status
    if (paymentIntent.status === 'succeeded') {
      await supabase
        .from('purchase_transactions')
        .update({
          transaction_status: 'completed',
          gateway_status: paymentIntent.status,
          completed_at: new Date().toISOString(),
        })
        .eq('id', transaction.id);

      // Credit user wallet with tokens
      const { error: walletError } = await supabase.rpc('add_transaction', {
        p_user_id: transaction.user_id,
        p_amount: transaction.token_amount,
        p_transaction_type: 'credit',
        p_description: `Token purchase via Stripe - ${paymentIntentId}`,
        p_reference_id: transaction.id,
      });

      if (walletError) {
        console.error('Failed to credit wallet:', walletError);
      }

      return new Response(JSON.stringify({
        transactionId: transaction.id,
        paymentStatus: 'succeeded',
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      });
    } else {
      // Update transaction to failed
      await supabase
        .from('purchase_transactions')
        .update({
          transaction_status: 'failed',
          gateway_status: paymentIntent.status,
        })
        .eq('id', transaction.id);

      return new Response(JSON.stringify({
        transactionId: transaction.id,
        paymentStatus: paymentIntent.status,
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      });
    }
  } catch (error) {
    console.log('Verify payment error:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400
    });
  }
});