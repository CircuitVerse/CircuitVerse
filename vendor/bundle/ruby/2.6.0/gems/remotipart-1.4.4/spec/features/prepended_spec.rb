require 'spec_helper'

describe 'prepended', type: :feature do
  context "when another library overrides #render using prepend" do
    it "does not break" do
      expect { visit prepended_path }.not_to raise_error
    end
  end
end