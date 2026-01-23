class Report < ApplicationRecord
  belongs_to :reporter
  belongs_to :reported_user
end
