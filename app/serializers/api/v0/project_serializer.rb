# frozen_string_literal: true

class Api::V0::ProjectSerializer
  include FastJsonapi::ObjectSerializer
  set_type :projects
  attributes :name, :description
  attribute :is_featured do |object|
    object.featured?
  end
  attribute :is_forked do |object|
    false if Project.find_by(object.forked_project_id).nil?
  end
  attribute :is_assigned do |object|
    false if Assignment.find_by(object.assignment_id).nil?
  end
  link :self do |object|
    "/api/v0/projects/#{object.id}"
  end

  belongs_to :author, class_name: "User"
  belongs_to :assignment, optional: true
  has_many :forks, class_name: "Project", foreign_key: "forked_project_id", dependent: :nullify
  has_many :stars, dependent: :destroy
  has_many :user_ratings, through: :stars, dependent: :destroy, source: "user"
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, source: "user", through: :collaborations
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_one :grade, dependent: :destroy
end
