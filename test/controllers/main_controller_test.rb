require "test_helper"

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get main_index_url
    assert_response :success
  end

  test "should get create" do
    get main_create_url
    assert_response :success
  end

  test "should get destroy" do
    get main_destroy_url
    assert_response :success
  end
end
