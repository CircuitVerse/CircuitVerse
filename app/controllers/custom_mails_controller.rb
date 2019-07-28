# frozen_string_literal: true

class CustomMailsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize CustomMail
  end

  def create
  end

  private
    def custom_mails_params
      params.require(:custom_mails).permit(:subject, :content)
    end
end
