FactoryBot.define do
  factory :item do
    association :merchant
    name { Faker::FunnyName.name }
    description { Faker::Lorem.sentence}
    unit_price { Faker::Number.between(from: 5000, to: 10000 ) }
    status { ["enabled", "disabled"].sample }
  end
end