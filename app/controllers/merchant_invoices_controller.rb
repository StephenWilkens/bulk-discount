class MerchantInvoicesController < ApplicationController

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @invoice = Invoice.find(params[:id])
  end

  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

end
