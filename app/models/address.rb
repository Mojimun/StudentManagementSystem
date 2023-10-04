class Address < ApplicationRecord
  belongs_to :student
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :pin, presence: true, numericality: { only_integer: true }, length: { is: 6, message: "PIN code must be exactly 6 digits" }
end
