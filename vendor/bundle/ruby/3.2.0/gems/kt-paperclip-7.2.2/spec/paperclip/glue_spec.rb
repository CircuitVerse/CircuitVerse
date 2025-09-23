# require "spec_helper"

describe Paperclip::Glue do
  describe "when ActiveRecord does not exist" do
    before do
      ActiveRecordSaved = ActiveRecord
      Object.send :remove_const, "ActiveRecord"
    end

    after do
      ActiveRecord = ActiveRecordSaved
      Object.send :remove_const, "ActiveRecordSaved"
    end

    it "does not fail" do
      NonActiveRecordModel = Class.new
      NonActiveRecordModel.include Paperclip::Glue
      Object.send :remove_const, "NonActiveRecordModel"
    end
  end

  describe "when ActiveRecord does exist" do
    before do
      if Object.const_defined?("ActiveRecord")
        @defined_active_record = false
      else
        ActiveRecord = :defined
        @defined_active_record = true
      end
    end

    after do
      Object.send :remove_const, "ActiveRecord" if @defined_active_record
    end

    it "does not fail" do
      NonActiveRecordModel = Class.new
      NonActiveRecordModel.include Paperclip::Glue
      Object.send :remove_const, "NonActiveRecordModel"
    end
  end

  describe "when included" do
    it "does not mutate I18n.load_path more than once" do
      before_load_path = I18n.load_path
      I18n.load_path = []

      # expect twice because the load_path is reset after creating the classes
      expect(I18n.config).to receive(:load_path=).and_call_original.twice

      FirstModel = Class.new
      FirstModel.include Paperclip::Glue

      SecondModel = Class.new
      SecondModel.include Paperclip::Glue

      ThirdModel = Class.new
      ThirdModel.include Paperclip::Glue

      I18n.load_path = before_load_path
    end
  end
end
