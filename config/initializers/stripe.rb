Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

Rails.application.config.stripe = {
  webhook_secret: ENV["STRIPE_WEBHOOK_SECRET"],
  price_id: ENV["STRIPE_PRICE_ID"]
}
