FactoryGirl.define do
  factory :todo do
    sequence(:title)  { |n| "Todo #{n}" }
  end
end
