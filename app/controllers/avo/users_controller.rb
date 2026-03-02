# frozen_string_literal: true

# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
class Avo::UsersController < Avo::ResourcesController
  def update
    strip_blank_password_params
    super
  end

  private

    def strip_blank_password_params
      %i[resource user].each do |key|
        next unless params[key].respond_to?(:delete)

        params[key].delete(:password) if params[key][:password].blank?
        params[key].delete(:password_confirmation) if params[key][:password_confirmation].blank?
      end
    end
end
