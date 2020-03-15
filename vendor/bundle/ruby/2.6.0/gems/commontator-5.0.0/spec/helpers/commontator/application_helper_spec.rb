require 'rails_helper'

module Commontator
  RSpec.describe ApplicationHelper, type: :helper do
    it 'must print output of javascript proc' do
      expect(javascript_proc).to eq '// Some javascript'
    end
  end
end

