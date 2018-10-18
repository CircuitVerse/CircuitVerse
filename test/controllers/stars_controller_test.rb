require 'test_helper'

class StarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @star = stars(:one)
  end

  test "should get index" do
    get stars_url
    assert_response :success
  end

  test "should get new" do
    get new_star_url
    assert_response :success
  end

  test "should create star" do
    assert_difference('Star.count') do
      post stars_url, params: { star: { project_id: @star.project_id, user_id: @star.user_id } }
    end

    assert_redirected_to star_url(Star.last)
  end

  test "should show star" do
    get star_url(@star)
    assert_response :success
  end

  test "should get edit" do
    get edit_star_url(@star)
    assert_response :success
  end

  test "should update star" do
    patch star_url(@star), params: { star: { project_id: @star.project_id, user_id: @star.user_id } }
    assert_redirected_to star_url(@star)
  end

  test "should destroy star" do
    assert_difference('Star.count', -1) do
      delete star_url(@star)
    end

    assert_redirected_to stars_url
  end
end
