FactoryGirl.define do
  factory :item do
    sequence(:title) { |n| "Item #{n}" }
    todo
  end
end
