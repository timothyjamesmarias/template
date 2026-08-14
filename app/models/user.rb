class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  # Google has already verified the address, so an OAuth signup skips the
  # confirmation email. Password signups still confirm.
  def self.from_google(auth)
    return nil unless auth.info.email_verified

    linked = find_by(provider: auth.provider, uid: auth.uid)
    return linked if linked

    user = find_or_initialize_by(email: auth.info.email)
    user.provider = auth.provider
    user.uid = auth.uid
    user.password = Devise.friendly_token[0, 32] if user.new_record?
    user.skip_confirmation! if user.new_record?
    user.save!
    user
  end

  def password_required?
    return false if provider.present? && encrypted_password.blank?

    super
  end
end
