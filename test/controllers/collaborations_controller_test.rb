require 'test_helper'

class CollaborationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @collaboration = collaborations(:one)
  end

  test "should get index" do
    get collaborations_url
    assert_response :success
  end

  test "should get new" do
    get new_collaboration_url
    assert_response :success
  end

  test "should create collaboration" do
    assert_difference('Collaboration.count') do
      post collaborations_url, params: { collaboration: { project_id: @collaboration.project_id, user_id: @collaboration.user_id } }
    end

    assert_redirected_to collaboration_url(Collaboration.last)
  end

  test "should show collaboration" do
    get collaboration_url(@collaboration)
    assert_response :success
  end

  test "should get edit" do
    get edit_collaboration_url(@collaboration)
    assert_response :success
  end

  test "should update collaboration" do
    patch collaboration_url(@collaboration), params: { collaboration: { project_id: @collaboration.project_id, user_id: @collaboration.user_id } }
    assert_redirected_to collaboration_url(@collaboration)
  end

  test "should destroy collaboration" do
    assert_difference('Collaboration.count', -1) do
      delete collaboration_url(@collaboration)
    end

    assert_redirected_to collaborations_url
  end
end
