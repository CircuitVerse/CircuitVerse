# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Rails.logger.debug "Creating Users"

User.create(name: "Admin",
            email: "admin@circuitverse.org",
            password: "password",
            admin: true,
            confirmed_at: Time.now
)
users = User.create([{ name: "user1", email: "user1@circuitverse.org", password: "password" },
                     { name: "user2", email: "user2@circuitverse.org", password: "password" }])

# private,public,limited access
Rails.logger.debug "Creating Projects"
projects = Project.create([{ name: "Private",
                             author_id: users.first.id,
                             project_access_type: "Private",
                             description: "description" },
                           { name: "Public",
                             author_id: users.first.id,
                             project_access_type: "Public",
                             description: "description" },
                           { name: "Limited access",
                             author_id: users.first.id,
                             project_access_type: "Limited access",
                             description: "description" }])

# examples
Rails.logger.debug "Creating Examples"
Project.create([{ name: "Full Adder",
                  author_id: users.first.id,
                  project_datum_attributes: { data: File.read("db/examples/fullAdder.json") },
                  project_access_type: "Public",
                  description: "description" },
                { name: "SAP",
                  author_id: users.first.id,
                  project_datum_attributes: { data: File.read("db/examples/SAP.json") },
                  project_access_type: "Public",
                  description: "SAP-1 short for simple as possible computer is a 8 Bit computer. It can perform simple operations like Addition and Subtraction." },
                { name: "ALU-74LS181",
                  author_id: users.first.id,
                  project_datum_attributes: { data: File.read("db/examples/ALU-74LS181.json") },
                  project_access_type: "Public",
                  description: "description" }])

#groups
puts "Creating Groups"
group = Group.create(name: 'group1',
  primary_mentor_id: users.first.id,
)
GroupMember.create(group_id: group.id,
                   user_id: users.second.id)

# tags
Rails.logger.debug "Creating Tags"
tag = Tag.create(name: "example")
Tagging.create([{ tag_id: tag.id,
                  project_id: projects.first.id },
                { tag_id: tag.id,
                  project_id: projects.second.id },
                { tag_id: tag.id,
                  project_id: projects.third.id }])

if Rails.env.development?
  puts "Seeding GSoC demo data..."
  mentor = User.find_or_create_by!(email: "mentor@college.edu") do |u|
    u.name         = "Demo Mentor"
    u.password     = "password123"
    u.confirmed_at = Time.zone.now
  end
  parent = Group.find_or_create_by!(name: "CS101 - Digital Design") do |g|
    g.primary_mentor = mentor
  end
  child = Group.find_or_create_by!(name: "Team A") do |g|
    g.primary_mentor = mentor
    g.parent_group   = parent
  end
  assignment = parent.assignments.find_or_create_by!(name: "Half Adder Lab") do |a|
    a.deadline    = 1.week.from_now
    a.description = "Build a half adder using XOR and AND gates"
    a.status      = "open"
  end
  TestCase.find_or_create_by!(assignment: assignment, description: "Both inputs HIGH — output HIGH") do |tc|
    tc.input = "A=1, B=1"
    tc.expected_output = "Y=1"
  end
  TestCase.find_or_create_by!(assignment: assignment, description: "Both inputs LOW — output LOW") do |tc|
    tc.input = "A=0, B=0"
    tc.expected_output = "Y=0"
  end
  TestCase.find_or_create_by!(assignment: assignment, description: "A HIGH, B LOW — output LOW") do |tc|
    tc.input = "A=1, B=0"
    tc.expected_output = "Y=0"
  end
  puts "Seeded: Group #{parent.id}, Subgroup #{child.id}, Assignment #{assignment.id}"
  puts "Test cases: #{assignment.test_cases.count}"
end
