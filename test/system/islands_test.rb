require "application_system_test_case"

class IslandsTest < ApplicationSystemTestCase
  test "stimulus controller handles small interactions on turbo pages" do
    visit root_path
    assert_selector "#greeting", text: "Hello from Vite"

    find("[data-action='click->copy-button#copy']").click
    assert_selector "[data-copy-button-target='label']", text: "Copied"
  end

  test "react page-app owns its subtree and holds client state" do
    sign_in_as email: "ada@example.com"

    visit dashboard_path
    assert_selector "[data-testid='dashboard']", text: "ada@example.com"

    fill_in_react "name-input", with: "Ada Lovelace"
    find("[data-testid='next']").click
    fill_in_react "email-input", with: "contact@example.org"
    find("[data-testid='next']").click

    assert_selector "[data-testid='review-name']", text: "Ada Lovelace"
    assert_selector "[data-testid='review-email']", text: "contact@example.org"
  end

  test "react pages opt out of turbo drive" do
    sign_in_as

    visit dashboard_path
    assert_selector "meta[name='turbo-visit-control'][content='reload']", visible: false
  end

  test "turbo pages do not load the react bundle" do
    visit root_path
    assert_no_selector "script[src*='dashboard']", visible: false
  end

  private

  def fill_in_react(testid, with:)
    find("[data-testid='#{testid}']").set(with)
  end
end
