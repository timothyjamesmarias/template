module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      user = User.from_google(request.env["omniauth.auth"])

      return redirect_to new_user_session_path, alert: t("devise.omniauth_callbacks.failure_default") if user.nil?

      sign_in_and_redirect user, event: :authentication
    end

    def failure
      redirect_to new_user_session_path, alert: failure_message
    end
  end
end
