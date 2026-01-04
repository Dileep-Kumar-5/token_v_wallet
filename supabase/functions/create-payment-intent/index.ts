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

    // Extract the token from the Authorization header
    const token = authHeader.replace('Bearer ', '');

    // Create a Supabase client using the token from the logged-in user
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
    const requestData = await req.json();
    const { amount, currency, transactionId, userId, transactionType, recipientId } = requestData;

    // Validate input data
    if (!amount || typeof amount !== 'number' || amount <= 0) {
      throw new Error('Invalid amount');
    }
    if (!currency || typeof currency !== 'string') {
      throw new Error('Invalid currency');
    }
    if (!transactionId || !userId) {
      throw new Error('Missing required transaction data');
    }

    // Get user information from the JWT token
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      throw new Error('User authentication failed');
    }

    // Create a Stripe payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      automatic_payment_methods: { enabled: true },
      description: `Token V Wallet - ${transactionType}`,
      metadata: {
        user_id: userId,
        transaction_id: transactionId,
        transaction_type: transactionType,
        recipient_id: recipientId || '',
      }
    });

    // Update transaction with Stripe payment intent ID
    await supabase
      .from('purchase_transactions')
      .update({
        gateway_transaction_id: paymentIntent.id,
        gateway_status: paymentIntent.status,
      })
      .eq('id', transactionId);

    // Return the payment intent client secret
    return new Response(JSON.stringify({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200
    });
  } catch (error) {
    console.log('Create payment intent error:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400
    });
  }
});