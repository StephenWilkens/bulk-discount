class DiscountService

  def self.next_3_holidays
    upcoming_holidays.first(3)
  end

  def self.upcoming_holidays
    get_url("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end

  def self.get_url(url)
    response = HTTParty.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end