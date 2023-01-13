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
      case @notific_type
      when "star"
        update_star
      when "fork"
        update_fork
      when "new_assignment"
        update_new_assignment
      else
        foo
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

    def update_new_assignment
      if @active == "true"
        @recipient.update!(new_assignment: "false")
      else
        @recipient.update!(new_assignment: "true")
      end
    end

    def update_all
      if @active == "true"
        @recipient.update!(star: "false", fork: "false", new_assignment: "false")
      else
        @recipient.update!(star: "true", fork: "true", new_assignment: "true")
      end
    end
end
