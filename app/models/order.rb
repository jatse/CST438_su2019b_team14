class Order < ApplicationRecord
    validates :itemId, presence: true, numericality: { only_integer: true }
    validates :customerId, presence: true, numericality: { only_integer: true }
    validates :award, presence: true, numericality: {greater_than_or_equal_to: 0}
    validates :description, presence: true
    validates :price, presence: true, numericality: {greater_than: 0}
    validates :total, presence: true, numericality: {greater_than_or_equal_to: 0}
    
end
