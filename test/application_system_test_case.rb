require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(email: "member@example.com", password: "password123")
    User.create!(email: email, password: password).confirm

    visit new_user_session_path
    find("[data-testid='email']").set(email)
    find("[data-testid='password']").set(password)
    find("[data-testid='submit']").click

    assert_selector "[data-testid='current-user']", text: email
  end
end
