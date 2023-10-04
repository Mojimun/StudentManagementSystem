class Profile < ApplicationRecord
  belongs_to :student
  has_one_attached :avatar
  validates :bio, presence: true
  validates :gender, presence: true
  validates :dob, presence: true
  validate :dob_cannot_be_in_future

  private

  def dob_cannot_be_in_future
    if dob.present? && dob > Date.current
      errors.add(:dob, "Date of Birth cannot be a future date")
    end
  end
end
