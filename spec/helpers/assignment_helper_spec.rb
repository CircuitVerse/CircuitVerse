# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentsHelper, type: :helper do
  before do
    @deadline_day = 2
    @deadline_month = 3
    @deadline_year = 2019
    @deadline_hour = 4
    @deadline_minute = 5
    @deadline_second = 6

    @deadline_datetime = DateTime.new(@deadline_year,
                                      @deadline_month,
                                      @deadline_day,
                                      @deadline_hour,
                                      @deadline_minute,
                                      @deadline_second)
    @group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user))
    @assignment = FactoryBot.create(:assignment, group: @group, deadline: @deadline_datetime)
  end

  it "#deadline_year" do
    expect(deadline_year(@assignment).to_i).to eq(@deadline_year)
  end

  it "#deadline_month" do
    expect(deadline_month(@assignment).to_i).to eq(@deadline_month)
  end

  it "#deadline_day" do
    expect(deadline_day(@assignment).to_i).to eq(@deadline_day)
  end

  it "#deadline_hour" do
    expect(deadline_hour(@assignment).to_i).to eq(@deadline_hour)
  end

  it "#deadline_minute" do
    expect(deadline_minute(@assignment).to_i).to eq(@deadline_minute)
  end

  it "#deadline_second" do
    expect(deadline_second(@assignment).to_i).to eq(@deadline_second)
  end
end
