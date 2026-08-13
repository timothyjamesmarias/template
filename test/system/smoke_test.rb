require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "renders the page with compiled tailwind styles" do
    visit root_path
    assert_selector "#greeting", text: "Hello from Vite"
    color = evaluate_script("getComputedStyle(document.getElementById('greeting')).color")
    assert_match(/oklch|rgb/, color)
    refute_equal "rgb(0, 0, 0)", color
  end
end
