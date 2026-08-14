require "test_helper"

class UserTest < ActiveSupport::TestCase
  def google_auth(email: "ada@example.com", uid: "google-123", verified: true)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, email_verified: verified }
    )
  end

  test "creates a confirmed user from a verified google account" do
    user = User.from_google(google_auth)

    assert user.persisted?
    assert user.confirmed?
    assert_equal "google_oauth2", user.provider
    assert_equal "google-123", user.uid
  end

  test "refuses to sign in an unverified google email" do
    assert_nil User.from_google(google_auth(verified: false))
    assert_equal 0, User.count
  end

  test "links google to an existing password account with the same email" do
    existing = User.create!(email: "ada@example.com", password: "password123")
    existing.confirm

    user = User.from_google(google_auth)

    assert_equal existing.id, user.id
    assert_equal "google-123", user.uid
    assert_equal 1, User.count
  end

  test "returns the same user on repeat google sign ins" do
    first = User.from_google(google_auth)
    second = User.from_google(google_auth)

    assert_equal first.id, second.id
    assert_equal 1, User.count
  end

  test "password signups must confirm before signing in" do
    user = User.create!(email: "new@example.com", password: "password123")

    assert_not user.confirmed?
    assert_not user.active_for_authentication?
  end
end
