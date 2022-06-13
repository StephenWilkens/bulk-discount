require "rails_helper"

RSpec.describe "merchant's invoice show page", type: :feature do
  before :each do
    @merch_1 = Merchant.create!(name: "Two-Legs Fashion")

    @item_1 = @merch_1.items.create!(name: "Two-Leg Pantaloons", description: "pants built for people with two legs", unit_price: 5000)
    @item_2 = @merch_1.items.create!(name: "Two-Leg Shorts", description: "shorts built for people with two legs", unit_price: 3000)

    @cust_1 = Customer.create!(first_name: "Debbie", last_name: "Twolegs")
    @cust_2 = Customer.create!(first_name: "Tommy", last_name: "Doubleleg")

    @invoice_1 = @cust_1.invoices.create!(status: 1)
    @invoice_2 = @cust_1.invoices.create!(status: 2)
    @invoice_3 = @cust_1.invoices.create!(status: 1)
    @invoice_4 = @cust_2.invoices.create!(status: 1)
    @invoice_5 = @cust_2.invoices.create!(status: 1)
    @invoice_6 = @cust_2.invoices.create!(status: 1, created_at: "2021-05-29 17:44:03 UTC")

    @ii_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: @item_1.unit_price, status: 0)
    @ii_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_2.id, quantity: 2, unit_price: @item_2.unit_price, status: 1)
  end

  it "shows invoice ID, invoice status, created at time formatted and customer name" do
    visit "/merchants/#{@merch_1.id}/invoices/#{@invoice_1.id})"

    expect(page).to have_content("Invoice ID: #{@invoice_1.id}")
    expect(page).to have_content("Status: in progress")
    expect(page).to have_content("#{@invoice_1.created_at.strftime( "%A, %b %e, %Y")}")
    expect(page).to have_content("Debbie Twolegs")

    expect(page).to_not have_content("#{@invoice_2.id}")
    expect(page).to_not have_content("#{@invoice_2.status}")
    expect(page).to_not have_content("#{@invoice_6.created_at}")
    expect(page).to_not have_content("Tommy Doubleleg")
  end

  it "shows item name, quantity, price, status from just this merchant" do
    merch = Merchant.create!(name: "Pants Pants Pants")
    item = merch.items.create!(name: "Test", description: "test", unit_price: 1000)

    invoice_item = InvoiceItem.create!(item_id: item.id, invoice_id: @invoice_1.id, quantity: 6, unit_price: item.unit_price, status: 1)

    visit "/merchants/#{@merch_1.id}/invoices/#{@invoice_1.id})"
    expect(page).to have_content("Two-Leg Pantaloons")
    expect(page).to have_content("Quantity: 1")
    expect(page).to have_content("Unit Price: $50.00")
    expect(find_field('ii_status').value).to eq("packaged")

    expect(page).to_not have_content("Two-Leg Shorts")
    expect(page).to_not have_content("Quantity: 2")
    expect(page).to_not have_content("Unit Price: $30.00")

    expect(page).to_not have_content("test")
    expect(page).to_not have_content("Quantity: 6")
    expect(page).to_not have_content("Unit Price: $10.00")
  end

  it "Shows sum of all items sold in receipt" do
    @item_3 = @merch_1.items.create!(name: "Hat", description: "hat built for people with two legs and one head", unit_price: 6000)
    @item_4 = @merch_1.items.create!(name: "Double Legged Pant", description: "pants built for people with two legs", unit_price: 50000)
    @ii_3 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: @item_3.unit_price, status: 2)
    @ii_4 = InvoiceItem.create!(item_id: @item_4.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: @item_4.unit_price, status: 2)


    visit "/merchants/#{@merch_1.id}/invoices/#{@invoice_1.id})"
    expect(page).to have_content("Total Revenue: $610.00")
  end

  it "can change the invoice status" do
    visit "/merchants/#{@merch_1.id}/invoices/#{@invoice_1.id}"
    #within the first item section
      within "#ii-#{@ii_1.id}" do
        expect(find_field('ii_status').value).to eq("packaged")
        select "pending"
        click_button "Update Invoice"
        expect(current_path).to eq( "/merchants/#{@merch_1.id}/invoices/#{@invoice_1.id}" )
        expect(page).to have_content('pending')
      end
  end

  it 'can return the total revenue of the invoice with discounts included' do 
   @merch_1 = Merchant.create!(name: "Two-Legs Fashion")
    @merch_2 = Merchant.create!(name: "Two-Legs Thomas")

    @item_1 = @merch_1.items.create!(name: "Two-Leg Pantaloons", description: "pants built for people with two legs", unit_price: 5000)
    @item_2 = @merch_1.items.create!(name: "Two-Leg Shorts", description: "shorts built for people with two legs", unit_price: 3000)
    @item_3 = @merch_1.items.create!(name: "Hat", description: "hat built for people with two legs and one head", unit_price: 6000)
    @item_4 = @merch_1.items.create!(name: "Double Legged Pant", description: "pants built for people with two legs", unit_price: 50000)
    @item_5 = @merch_1.items.create!(name: "Stainless Steel, 5-Pocket Jean", description: "Shorts of Steel", unit_price: 3000000)
    @item_6 = @merch_1.items.create!(name: "String of Numbers", description: "54921752964273", unit_price: 100)

    @cust_1 = Customer.create!(first_name: "Debbie", last_name: "Twolegs")
    @cust_2 = Customer.create!(first_name: "Tommy", last_name: "Doubleleg")
    @cust_3 = Customer.create!(first_name: "Brian", last_name: "Twinlegs")
    @cust_4 = Customer.create!(first_name: "Jared", last_name: "Goffleg")
    @cust_5 = Customer.create!(first_name: "Pistol", last_name: "Pete")
    @cust_6 = Customer.create!(first_name: "Bronson", last_name: "Shmonson")
    @cust_7 = Customer.create!(first_name: "Anten", last_name: "Branden")

    @invoice_1 = @cust_1.invoices.create!(status: 1)
    @invoice_2 = @cust_1.invoices.create!(status: 1)
    @invoice_3 = @cust_1.invoices.create!(status: 1)
    @invoice_4 = @cust_2.invoices.create!(status: 1)
    @invoice_5 = @cust_2.invoices.create!(status: 1)
    @invoice_6 = @cust_2.invoices.create!(status: 1)
    @invoice_7 = @cust_3.invoices.create!(status: 1)
    @invoice_8 = @cust_3.invoices.create!(status: 1)
    @invoice_9 = @cust_4.invoices.create!(status: 1)
    @invoice_10 = @cust_4.invoices.create!(status: 1)
    @invoice_11 = @cust_5.invoices.create!(status: 1)
    @invoice_12 = @cust_5.invoices.create!(status: 1)
    @invoice_13 = @cust_6.invoices.create!(status: 1)
    @invoice_14 = @cust_7.invoices.create!(status: 1)
    @invoice_15 = @cust_7.invoices.create!(status: 2)

    @ii_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_2 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_2.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_3 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_3.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_4 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_4.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_5 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_5.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_6 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_6.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_7 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_7.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_8 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_8.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_9 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_9.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)
    @ii_10 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_10.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)

    @ii_11 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_8.id, quantity: 10, unit_price: @item_1.unit_price, status: 2)
    @ii_12 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_8.id, quantity: 20, unit_price: @item_2.unit_price, status: 2)
    @ii_13 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_9.id, quantity: 20, unit_price: @item_1.unit_price, status: 2)
    @ii_14 = InvoiceItem.create!(item_id: @item_4.id, invoice_id: @invoice_9.id, quantity: 50, unit_price: @item_2.unit_price, status: 2)
    @ii_15 = InvoiceItem.create!(item_id: @item_6.id, invoice_id: @invoice_14.id, quantity: 1, unit_price: @item_4.unit_price, status: 2)
    @ii_16 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_14.id, quantity: 30, unit_price: @item_1.unit_price, status: 2)
    @ii_17 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_14.id, quantity: 30, unit_price: @item_2.unit_price, status: 2)
    @ii_18 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_14.id, quantity: 30, unit_price: @item_3.unit_price, status: 2)
    @ii_19 = InvoiceItem.create!(item_id: @item_5.id, invoice_id: @invoice_15.id, quantity: 700, unit_price: @item_4.unit_price, status: 0)

    @transaction_1 = @invoice_1.transactions.create!(credit_card_number: 4039485738495837, result: "success")
    @transaction_2 = @invoice_2.transactions.create!(credit_card_number: 4039485738495837, result: "success")
    @transaction_3 = @invoice_3.transactions.create!(credit_card_number: 4039485738495837, result: "success")
    @transaction_4 = @invoice_4.transactions.create!(credit_card_number: 4847583748374837, result: "success")
    @transaction_5 = @invoice_5.transactions.create!(credit_card_number: 4847583748374837, result: "success")
    @transaction_6 = @invoice_6.transactions.create!(credit_card_number: 4847583748374837, result: "success")
    @transaction_7 = @invoice_7.transactions.create!(credit_card_number: 4364756374652636, result: "success")
    @transaction_8 = @invoice_8.transactions.create!(credit_card_number: 4364756374652636, result: "success")
    @transaction_9 = @invoice_9.transactions.create!(credit_card_number: 4928294837461125, result: "success")
    @transaction_10 = @invoice_10.transactions.create!(credit_card_number: 4928294837461125, result: "success")
    @transaction_11 = @invoice_11.transactions.create!(credit_card_number: 4738473664751832, result: "success")
    @transaction_12 = @invoice_12.transactions.create!(credit_card_number: 4738473664751832, result: "success")
    @transaction_13 = @invoice_13.transactions.create!(credit_card_number: 4023948573948293, result: "success")
    @transaction_14 = @invoice_14.transactions.create!(credit_card_number: 4023948573948293, result: "success")
    @transaction_15 = @invoice_15.transactions.create!(credit_card_number: 4023948573948293, result: "success")

    @discount1 = Discount.create!(name: "10 at 10", percentage_discount: 10, quantity_threshold: 10, merchant_id: @merch_1.id)
    @discount2 = Discount.create!(name: "15 at 15", percentage_discount: 15, quantity_threshold: 15, merchant_id: @merch_1.id)
    @discount3 = Discount.create!(name: "20 at 20", percentage_discount: 20, quantity_threshold: 20, merchant_id: @merch_2.id)
    @discount4 = @merch_1.discounts.create!(name: "lads", percentage_discount: 4, quantity_threshold: 69)
   
    visit "/merchants/#{@merch_1.id}/invoices/#{@invoice_8.id}"
    expect(page).to have_content("Total Revenue with Discounts: $ 1010.00")
  end
end
