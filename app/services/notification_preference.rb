# frozen_string_literal: true

class NotificationPreference < ApplicationController
  def initialize(params)
    super()
    @recipient = User.find(params[:id])
    @notific_type = params[:type]
    @active = params[:active]
    @count = params[:count]
  end

  def call
    if @count == "1"
      change_preferences
    else
      update_all
    end
  end

  private

    def change_preferences
      case @notific_type
      when "fork"
        if @active == "true"
          @recipient.update!(fork: "false")
        else
          @recipient.update!(fork: "true")
        end
      else
        if @active == "true"
          @recipient.update!(star: "false")
        else
          @recipient.update!(star: "true")
        end
      end
    end

    def update_all
      if @active == "true"
        @recipient.update!(star: "false", fork: "false")
      else
        @recipient.update!(star: "true", fork: "true")
      end
    end
end
