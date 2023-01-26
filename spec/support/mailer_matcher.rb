# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :send_email do |mailer_action|
  match do |mailer_class|
    message_delivery = instance_double(ActionMailer::MessageDelivery)
    allow(mailer_class).to receive(mailer_action).and_return(message_delivery)
    allow(message_delivery).to receive(:deliver_later)
  end
end
