# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name: 'Admin',
  email: 'admin@circuitverse.org',
  password: 'password',
  admin: true
)
users = User.create([{ name: 'user1',email: 'user1@circuitverse.org',password: 'password' },
  { name: 'user2',email: 'user2@circuitverse.org',password: 'password' }])
group = Group.create(name: 'group1',
  mentor_id: users.first.id,
)
GroupMember.create(group_id: group.id,
  user_id: users.second.id,
)
