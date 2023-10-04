class Student < ApplicationRecord
  belongs_to :user
  has_one :profile, dependent: :destroy
  has_one :address, dependent: :destroy
  has_one :subject, dependent: :destroy
  validates :name, presence: true, format: { with: /\A[A-Za-z]+(?: [A-Za-z]+){0,2}\z/, message: "Only alphabets are allowed" }
  validates_associated :profile, :address
end
