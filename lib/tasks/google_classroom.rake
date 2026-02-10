namespace :google_classroom do
  desc "Clear Google OAuth tokens to force re-authentication with new scopes"
  task clear_tokens: :environment do
    count = User.where.not(google_access_token: nil).update_all(
      google_access_token: nil,
      google_refresh_token: nil
    )
    puts "Cleared Google tokens for #{count} users"
    puts "Users will need to sign in with Google again to grant new permissions"
  end
end
