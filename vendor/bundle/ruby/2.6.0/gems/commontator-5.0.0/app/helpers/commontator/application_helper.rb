module Commontator
  module ApplicationHelper
    def javascript_proc
      Commontator.javascript_proc.call(self).html_safe
    end
  end
end
