require 'csv'
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

  def save_mass_data_upload
    if current_user.role == 'Admin'
      csv_file = params[:csv_file]
      file_extension = File.extname(csv_file.original_filename)
      @error_msg = ""
    
      if file_extension == ".csv"
        total_count = 0
        directory = File.join(Rails.root, 'public', 'uploads')
    
        unless File.directory?(directory)
          FileUtils.mkdir_p directory, mode: 0777 rescue nil
        end
    
        time = Time.now.strftime("%m_%d_%Y_%I_%M_%S%p")
        file_name = csv_file.original_filename.gsub(file_extension, "").gsub(" ", "_")
        target_file_name = "#{file_name}_#{time}#{file_extension}"
        target_file_name_path = "#{directory}/#{target_file_name}"
    
        FileUtils.move csv_file.path, target_file_name_path
        File.open(target_file_name_path, "wb") { |f| f.write(csv_file.read) }
    
        CSV.foreach(target_file_name_path, headers: true) do |row|
          begin
            user = User.find_by(email: row['Email'])
    
            if user.nil?
              generated_password = Devise.friendly_token.first(8)
              user = User.new(email: row['Email'])
              user.password = generated_password
              user.password_confirmation = generated_password
              user.build_student(name: row['Name'])
              user.student.build_profile(bio: row['Bio'], dob: row['Date of Birth'], gender: row['Gender'])
              user.student.build_address(street: row['Street'], city: row['City'], state: row['State'], pin: row['Pin'])
              if user.save
                total_count += 1
              end
            end
          rescue StandardError => e 
            Rails.logger.error("Error processing CSV row: #{e.message}")
          end
        end
    
        @error_msg = total_count > 0 ? "File Processed Successfully" : "Records already exist"
      else
        @error_msg = "Format of file is not supported"
      end
      render plain: @error_msg
    else 
      redirect_to root_path
    end
  end

  def add_student
    if current_user.role == 'Admin'
      user = User.find_by(email: user_params[:email])
      if user.nil?
        generated_password = Devise.friendly_token.first(8)
        user = User.new(email: user_params[:email], password: generated_password, password_confirmation: generated_password)
        
        student_params = user_params[:student]
        user.build_student(name: student_params[:name])
        user.student.build_profile(student_params[:profile])
        user.student.build_address(student_params[:address])
      
        if user.save
          flash[:notice] = 'Student Added Successfully.'
          redirect_to root_path
        else
          flash[:alert] = 'Something went wrong.'
          redirect_back(fallback_location: root_path)
        end
      else
        flash[:alert] = 'Student already exist.'
        redirect_back(fallback_location: root_path)
      end
    else 
      redirect_to root_path
    end
  end

  def get_student_data
    if current_user.role == 'Admin'
      user = User.find(params[:id].first)
      user_data = nil
      if !user.nil?
        user_data = {
          id: user.id,
          name: user.student.name,
          email: user.email,
          bio: user.student.profile.bio,
          dob: user.student.profile.dob,
          gender: user.student.profile.gender,
          address: user.student.address,
        }
      end
      render :json => user_data
    else 
      redirect_to root_path
    end
  end

  def update_student
    if current_user.role == 'Admin'
      user = User.find(user_params[:id])
      if user.nil?
        flash[:alert] = 'Student not found.'
        redirect_back(fallback_location: root_path)
      else
        email_exist = User.where(email: user_params[:email]).where.not(id: user_params[:id]).first
        if email_exist.nil?
          user.update(email: user_params[:email])
          student_params = user_params[:student]
          if user.student
            user.student.update(name: student_params[:name])
            if user.student.profile
              user.student.profile.update(student_params[:profile])
            end
            if user.student.address
              user.student.address.update(student_params[:address])
            end
            flash[:notice] = 'Student Updated Successfully.'
            redirect_to root_path
          else
            flash[:alert] = 'Student data not found.'
            redirect_back(fallback_location: root_path)
          end
        else
          flash[:alert] = 'Email already Exist.'
          redirect_back(fallback_location: root_path)
        end
      end
    else
      flash[:alert] = 'You do not have permission to perform this action.'
      redirect_to root_path
    end
  end  
  
  private
  
  def user_params
    params.require(:user).permit(
      :id,
      :email,
      student: [:name, profile: [:bio, :dob, :gender, :avatar], address: [:street, :city, :state, :pin]]
    )
  end
  
end