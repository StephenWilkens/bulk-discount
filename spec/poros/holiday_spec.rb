require 'rails_helper'

RSpec.describe Holiday do 

  it "exists and has readable attributes" do
    independance_day = Holiday.new({name: 'Fourth of July', date: "07/04/2022"})

    expect(independance_day.name).to eq("Fourth of July")
    expect(independance_day.date).to eq("07/04/2022")

  end
end