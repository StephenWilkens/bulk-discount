class DiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])    
    @discount = Discount.find(params[:discount_id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @discount = Discount.new
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    discount = Discount.new(discount_params)
    if discount.save
      redirect_to "/merchants/#{@merchant.id}/discounts"
    else
      flash[:alert] = 'Unable to Create Discount'
      redirect_to "/merchants/#{@merchant.id}/discounts/new"
    end
  end

  def destroy
    merchant = Merchant.find(params[:merchant_id])
    discount = Discount.find(params[:discount_id])
    discount.destroy
    redirect_to "/merchants/#{merchant.id}/discounts"
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = Discount.find(params[:discount_id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    discount = Discount.find(params[:discount_id])
    if discount.update(discount_params)
      redirect_to "/merchants/#{merchant.id}/discounts/#{discount.id}"
    else
      flash[:alert] = 'Unable to Update Discount'
      redirect_to "/merchants/#{merchant.id}/discounts/#{discount.id}/edit"
    end
  end

  private
  def discount_params
    params.permit(:name, :percentage_discount, :quantity_threshold, :merchant_id)
  end
end