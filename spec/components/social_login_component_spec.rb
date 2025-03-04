# frozen_string_literal: true

require "rails_helper"

class DeviseMapping
  def confirmable?
    true
  end
end

RSpec.describe AuthComponents::SocialLoginComponent, type: :component do
  let(:devise_mapping) { instance_double(DeviseMapping, confirmable?: true) }
  let(:resource_name) { :user }

  it "renders the social login component" do
    render_inline(described_class.new(devise_mapping: devise_mapping, resource_name: resource_name))

    aggregate_failures do
      expect(page).to have_css(".users-social-links")
      expect(page).to have_css("img[alt='Google Icon']")
      expect(page).to have_css("img[alt='Facebook Icon']")
      expect(page).to have_css("img[alt='Github Icon']")
      expect(page).to have_content(I18n.t("users.shared.login_with"))
      expect(page).to have_link(I18n.t("users.shared.resend_email"))
    end
  end
end
