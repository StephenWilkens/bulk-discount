class HolidayFacade

  def holidays
    next_3 = DiscountService.next_3_holidays
    next_3.map do |data|
      Holiday.new(data)
    end
  end
end