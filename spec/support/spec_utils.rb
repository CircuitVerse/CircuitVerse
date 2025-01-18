# frozen_string_literal: true

# common utilities for specs
module SpecUtils
  def check_auth_exception(policy, action)
    expect do
      policy.public_send(:"#{action}?")
    end.to raise_error(ApplicationPolicy::CustomAuthException)
  end

  def check_not_authorized(response)
    expect(response.body).to eq("You are not authorized to do the requested operation")
  end

  def sign_in_random_user
    user = FactoryBot.create(:user)
    sign_in user
    user
  end

  def sign_in_group_mentor(group)
    user = FactoryBot.create(:user)
    group.group_members.create(user: user, group: group, mentor: true)
    sign_in user
    user
  end

  def get_group_member(group, member = FactoryBot.create(:user))
    FactoryBot.create(:group_member, user: member, group: group)
    member
  end

  def check_project_access_error(response)
    expect(response.body).to eq("Not Authorized: Project has been moved or deleted. " \
                                "If you are the owner of the project, Please check your project access privileges.")
  end

  def file_like_object
    dummy_file = Struct.new(:path) do
      def write(data); end
    end

    dummy_file.new(Faker::File.file_name)
  end
end
