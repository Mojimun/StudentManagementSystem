class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  
  has_one :student, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  validates_associated :student
  
  def self.user_verify(params)
    error = []
    msg = "Success"
    ids = params[:ids]
    ids.each do |id|
      user = User.find(id)
      if !user.nil?
        next if user.student.verified
        user.student.verified = true
        user.student.save
        error << id
        if user.student.verified
          generated_password = Devise.friendly_token.first(6)
          user.update(password: generated_password, password_confirmation: generated_password)
          StudentVerificationMailer.send_temp_password(user, generated_password).deliver
        end
      end
    end
    msg = "Error" if error.length == 0
    return msg
  end

  def self.user_delete(ids)
    error = []
    msg = "Success"
    ids.each do |id|
      begin
        user = User.find(id)
        if !user.nil?
          user.destroy
          error << id
        end
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error("User with ID #{id} not found.")
      rescue StandardError => e
        Rails.logger.error("An error occurred while deleting user with ID #{id}: #{e.message}")
      end
    end
    msg = "Error" if error.length == 0
    return msg
  end
  
end
