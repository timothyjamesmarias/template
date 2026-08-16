module Settings
  class BillingsController < BaseController
    def show
      @user = current_user
    end

    def portal
      session = Stripe::BillingPortal::Session.create(
        customer: current_user.stripe_customer.id,
        return_url: settings_billing_url
      )

      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      redirect_to settings_billing_path, alert: "Could not open the billing portal: #{e.message}"
    end
  end
end
