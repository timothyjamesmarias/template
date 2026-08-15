require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # The first browser interaction in a run waits on Vite serving assets, which
  # exceeds Capybara's 2s default.
  Capybara.default_max_wait_time = 10

  # KNOWN ISSUE: this is flaky at roughly 1 in 5. Turbo intermittently re-renders
  # the sign-in page after Capybara fills it, clearing the inputs, so an empty
  # form is submitted and Devise re-renders without an error. Waiting on
  # readyState, window.Turbo, window.Stimulus, turbo-loading, and refilling the
  # fields were all tried and none fixed it. Needs a real look at Turbo's
  # rendering lifecycle rather than another wait condition.
  def sign_in_as(email: "member@example.com", password: "password123", admin: false)
    User.create!(email: email, password: password, admin: admin).confirm

    visit new_user_session_path
    within "form" do
      fill_in "Email", with: email
      fill_in "Password", with: password
      click_on "Sign in"
    end

    assert_selector "[data-testid='current-user']", text: email
  end
end
