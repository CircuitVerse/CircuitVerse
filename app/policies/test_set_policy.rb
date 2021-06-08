class TestSetPolicy < ApplicationPolicy
  attr_reader :user, :test_set

  def initialize(user, test_set)
    @user = user
    @test_set = test_set  
  end

  def show_access?
    # TODO: Change to accomodate multiple mentors
    @test_set.testset_access_type == "Public" \
    || @test_set.author_id == user.id
    || @test_set.assignment.group.mentor_id == user.id
  end

  def edit_access?
    @test_set.author_id == user.id
  end

end
