require 'rails_helper'

RSpec.describe 'merchant discounts new page' do
  it 'can create a new merchant discount' do 
    @merch_1 = Merchant.create!(name: "Two-Legs Fashion")

    visit "/merchants/#{@merch_1.id}/discounts/new"
    fill_in :Name, with: "30 at 30"
    fill_in 'Discount Percentage', with: 30
    fill_in 'Quantity Threshold', with: 30
    click_button 'Submit'
    expect(current_path).to eq("/merchants/#{@merch_1.id}/discounts")
    expect(page).to have_content('30 at 30')
  end
end 