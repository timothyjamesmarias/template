class StripeWebhooksController < ActionController::Base
  # Stripe posts here with no session and no CSRF token.
  skip_forgery_protection

  def create
    event = verified_event
    return head :bad_request if event.nil?

    case event.type
    when "customer.subscription.created", "customer.subscription.updated"
      sync_subscription(event.data.object)
    when "customer.subscription.deleted"
      clear_subscription(event.data.object)
    when "invoice.payment_failed"
      mark_past_due(event.data.object)
    end

    head :ok
  end

  private

  def verified_event
    Stripe::Webhook.construct_event(
      request.body.read,
      request.env["HTTP_STRIPE_SIGNATURE"],
      Rails.application.config.stripe[:webhook_secret]
    )
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    nil
  end

  def sync_subscription(subscription)
    user = user_for(subscription.customer)
    return if user.nil?

    user.update_columns(
      stripe_subscription_id: subscription.id,
      subscription_status: subscription.status,
      plan: subscription.items.data.first&.price&.id
    )
  end

  def clear_subscription(subscription)
    user = user_for(subscription.customer)
    return if user.nil?

    user.update_columns(
      stripe_subscription_id: nil,
      subscription_status: "canceled",
      plan: nil
    )
  end

  def mark_past_due(invoice)
    user = user_for(invoice.customer)
    return if user.nil?

    user.update_column(:subscription_status, "past_due")
  end

  def user_for(customer_id)
    User.find_by(stripe_customer_id: customer_id)
  end
end
