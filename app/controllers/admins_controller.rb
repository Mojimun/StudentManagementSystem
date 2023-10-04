class AdminsController < ApplicationController
  before_action :authenticate_user! 
  def index
    redirect_to root_path if current_user.role != 'Admin'
  end
  def all_user
    if current_user.role == 'Admin'
      user_data = User.includes(student: [:profile, :address, :subject]).where.not(role: "Admin").map do |user|
        {
          id: user.id,
          name: user.student&.name,
          verified: user.student&.verified,
          email: user.email,
          dob: user.student.profile&.dob,
          subject: user.student.subject.nil? ? "Not enroll yet" : user.student.subject&.name,
          gender: user.student.profile&.gender,
          address: user.student.address,
          avatar_url: user.student.profile.avatar.attached? ? url_for(user.student.profile.avatar) : "https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg"
        }
      end    
      render :json => user_data
    else 
      redirect_to root_path
    end
  end

  def user_verify
    if current_user.role == 'Admin'
      message = User.user_verify(params)
      render :json => {message: message}
    else 
      redirect_to root_path
    end
  end

  def user_delete
    if current_user.role == 'Admin'
      data = User.user_delete(params[:ids])
      render :json => {message: data}
    else 
      redirect_to root_path
    end
  end

  def subject_wise_students_count
    if current_user.role == 'Admin'
      data = Subject.subject_wise_students_count
      render :json =>  data
    else 
      redirect_to root_path
    end
  end
end
  