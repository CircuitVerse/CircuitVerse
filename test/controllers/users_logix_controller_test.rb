require 'test_helper'

class UsersLogixControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post user_session_path, params: {user: {
      email:    users(:one).email,
      password: "password"
    }}

    get root_path
    assert_response :success
  end

  test "should get user projects" do
    get user_projects_path(:id => @user.id)
    assert_response :success
  end
  test "should get user profile" do
    get profile_path(:id => @user.id)
    assert_response :success
  end
  test "should get user favourites" do
    get user_favourites_path(:id => @user.id)
    assert_response :success
  end
  test "should get user groups" do
    get user_groups_path(:id => @user.id)
    assert_response :success
  end
  test "should get profile edit" do
    get profile_edit_path(:id => @user.id)
    assert_response :success
  end

  test "should update user profile" do
    patch profile_update_path(@user), params:{id:@user.id,user:{"name"=>"Jd", "country"=>"IN", "educational_institute"=>"MAIT"}}
    @user.reload
    assert_redirected_to profile_path(:id => @user.id)
    assert_equal "Jd", @user.name
    assert_equal "MAIT", @user.educational_institute
    assert_equal "IN", @user.country
  end




end
