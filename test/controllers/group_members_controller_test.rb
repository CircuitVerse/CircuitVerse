require 'test_helper'

class GroupMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group_member = group_members(:one)
  end

  test "should get index" do
    get group_members_url
    assert_response :success
  end

  test "should get new" do
    get new_group_member_url
    assert_response :success
  end

  test "should create group_member" do
    assert_difference('GroupMember.count') do
      post group_members_url, params: { group_member: { group_id: @group_member.group_id, user_id: @group_member.user_id } }
    end

    assert_redirected_to group_member_url(GroupMember.last)
  end

  test "should show group_member" do
    get group_member_url(@group_member)
    assert_response :success
  end

  test "should get edit" do
    get edit_group_member_url(@group_member)
    assert_response :success
  end

  test "should update group_member" do
    patch group_member_url(@group_member), params: { group_member: { group_id: @group_member.group_id, user_id: @group_member.user_id } }
    assert_redirected_to group_member_url(@group_member)
  end

  test "should destroy group_member" do
    assert_difference('GroupMember.count', -1) do
      delete group_member_url(@group_member)
    end

    assert_redirected_to group_members_url
  end
end
