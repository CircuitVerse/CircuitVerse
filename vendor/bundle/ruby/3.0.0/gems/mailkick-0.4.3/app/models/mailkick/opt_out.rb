module Mailkick
  class OptOut < ActiveRecord::Base
    self.table_name = "mailkick_opt_outs"

    belongs_to :user, polymorphic: true, optional: true
  end
end
