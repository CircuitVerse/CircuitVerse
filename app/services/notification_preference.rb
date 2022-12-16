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
      if @notific_type == "star"
        update_star
      else
        update_fork
      end
    else
      update_all
    end
  end

  private

    def update_fork
      if @active == "true"
        @recipient.update!(fork: "false")
      else
        @recipient.update!(fork: "true")
      end
    end

    def update_star
      if @active == "true"
        @recipient.update!(star: "false")
      else
        @recipient.update!(star: "true")
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
