class AddPlatformPublicKeyToLtiDeployments < ActiveRecord::Migration[8.0]
  def change
    add_column :lti_deployments, :platform_public_key, :text
  end
end
