class Item < ApplicationRecord
  belongs_to :todo

  scope :incomplete, -> { where(completed: false) }
end
