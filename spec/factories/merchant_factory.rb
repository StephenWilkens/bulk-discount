FactoryBot.define do
  factory :merchant do
    name { Faker::FunnyName.name }
    status { ["enabled", "disabled"].sample }
  end
end