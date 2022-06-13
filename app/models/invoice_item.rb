class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_one :merchant, through: :item
  has_many :discounts, through: :merchant

  validates_presence_of :quantity, :unit_price

  enum status: ['packaged', 'pending', 'shipped']

  validates :status, inclusion: { in: statuses.keys }

  def total_rev
    unit_price * quantity
  end

  def top_discount
    discounts.where('discounts.quantity_threshold <= ?', quantity)
              .select('discounts.*')
              .order(percentage_discount: :desc)
              .first
  end

   def apply_discount
    if top_discount
      total_rev - (total_rev * (top_discount.percentage_discount.to_f / 100))
    else
      total_rev.to_f 
    end
   end


end