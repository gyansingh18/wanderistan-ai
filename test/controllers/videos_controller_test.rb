require "test_helper"

class VideosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get videos_index_url
    assert_response :success
  end

  test "should get create" do
    get videos_create_url
    assert_response :success
  end
end
