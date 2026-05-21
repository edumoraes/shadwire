# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "showcase renders semantic component markup" do
    get root_path

    assert_response :success
    assert_select "main"
    assert_select "button[type='button']", text: "Default"
    assert_select "[role='alert']", text: /Components render/
    assert_select "[role='separator'][aria-orientation='horizontal']"
    assert_select "img[alt='Example user']"
  end
end
