# frozen_string_literal: true

require "rails_helper"

describe ProfileDecorator do
    def decorated_profile
        ProfileDecorator.new(@user)
    end

    before do
        @user = FactoryBot.create(:user)
    end

    describe "#educational_institute" do
        contest "Institute has been given" do
            it "gives institute string" do
                FactoryBot.create(:user, educational_institute: "Institute")
                expect(decorated_profile.educational_institute).to eq("Institute")
            end
        end

        context "Institute has not been given" do
            it "gives institute name n.a." do
                expect(decorated_profile.educational_institute).to eq("N.A.")
            end
        end
    end

    describe "#mail_subscription" do
        contest "Subscribed to mail" do
            it "Gives true boolean" do
                FactoryBot.create(:user, subscribed: true)
                expect(decorated_profile.mail_subscription).to eq("true")
            end
        end

        contest "Not Subscribed to mail" do
            it "Gives false boolean" do
                FactoryBot.create(:user, subscribed: false)
                expect(decorated_profile.mail_subscription).to eq("false")
            end
        end
    end
end
