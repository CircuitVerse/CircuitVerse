# frozen_string_literal: true

module Rails
  class Conductor::ActionMailbox::InboundEmailsController < Rails::Conductor::BaseController
    def index
      @inbound_emails = ActionMailbox::InboundEmail.order(created_at: :desc)
    end

    def new
    end

    def show
      @inbound_email = ActionMailbox::InboundEmail.find(params[:id])
    end

    def create
      inbound_email = create_inbound_email(new_mail)
      redirect_to main_app.rails_conductor_inbound_email_url(inbound_email)
    end

    private
      def new_mail
        Mail.new(params.require(:mail).permit(:from, :to, :cc, :bcc, :in_reply_to, :subject, :body).to_h).tap do |mail|
          mail[:bcc]&.include_in_headers = true
          params[:mail][:attachments].to_a.each do |attachment|
            mail.add_file(filename: attachment.original_filename, content: attachment.read)
          end
        end
      end

      def create_inbound_email(mail)
        ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.to_s)
      end
  end
end
