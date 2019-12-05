# frozen_string_literal: true

class CustomMailsController < ApplicationController
  include CustomMailsHelper

  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_mail, only: [:edit, :update, :show, :send_mail, :send_mail_self]

  def show
    @user = current_user
  end

  def new
  end

  def edit
  end

  def create
    @mail = CustomMail.new(subject: custom_mails_params[:subject],
                           content: custom_mails_params[:content],
                           sender: current_user)

    respond_to do |format|
      if @mail.save
        format.html { redirect_to custom_mail_path(@mail) }
        format.json { render json: { message: "Mail created" }, status: 200 }
      else
        format.html { render :new }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mail.update(custom_mails_params)
        format.html { redirect_to custom_mail_path(@mail) }
        format.json { render json: { message: "Mail updated" }, status: 200 }
      else
        format.html { render :edit }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def send_mail
    @mail.sent = true
    @mail.save

    send_mail_in_batches(@mail)

    render html: "The mails were queued for sending!"
  end

  def send_mail_self
    send_mail_to_self(current_user, @mail)

    render html: "A mail has been sent to your email!"
  end

  private

    def authorize_admin
      authorize CustomMail.new, :admin?
    end

    def set_mail
      @mail = CustomMail.find(params[:id])
    end

    def custom_mails_params
      params.require(:custom_mail).permit(:subject, :content)
    end
end
