require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "signing up requires email confirmation before signing in" do
    visit new_user_registration_path
    find("[data-testid='email']").set("new@example.com")
    find("[data-testid='password']").set("password123")
    find("[data-testid='password-confirmation']").set("password123")
    find("[data-testid='submit']").click

    assert_selector "[data-testid='flash-notice']", text: /confirmation link/i
    assert_selector "[data-testid='sign-in']"
  end

  test "a confirmed user can sign in and out" do
    sign_in_as email: "member@example.com"

    find("[data-testid='sign-out']").click
    assert_selector "[data-testid='sign-in']"
  end

  test "unauthenticated visitors are redirected away from protected pages" do
    visit dashboard_path

    assert_current_path new_user_session_path
    assert_selector "[data-testid='flash-alert']"
  end

  test "the google button is hidden when oauth credentials are absent" do
    visit new_user_session_path

    assert_no_selector "[data-testid='google-sign-in']"
  end
end
