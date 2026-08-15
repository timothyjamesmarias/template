require "application_system_test_case"

class IslandsTest < ApplicationSystemTestCase
  test "react page-app owns its subtree and holds client state" do
    sign_in_as email: "ada@example.com"

    visit dashboard_path
    assert_selector "[data-testid='dashboard']", text: "ada@example.com"

    find("[data-testid='name-input']").set("Ada Lovelace")
    find("[data-testid='next']").click
    assert_selector "[data-testid='email-input']"

    find("[data-testid='email-input']").set("contact@example.org")
    find("[data-testid='next']").click

    assert_selector "[data-testid='review-name']", text: "Ada Lovelace"
    assert_selector "[data-testid='review-email']", text: "contact@example.org"
  end

  test "turbo pages do not load the react bundle" do
    visit root_path

    assert_no_selector "script[src*='dashboard']", visible: false
  end
end
