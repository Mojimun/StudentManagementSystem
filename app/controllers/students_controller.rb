class StudentsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :configure_permitted_parameters, only: [:create, :update]

  def index
    redirect_to root_path if current_user.role != 'Student'
  end

  def edit
    redirect_to root_path if current_user.role != 'Student'
  end

  def update
    if current_user.role == 'Student'
      user = current_user
      if user.valid_password?(params[:user][:current_password])
        student_params = account_update_params[:student]
        if user.student
          user.student.update(student_params.except(:profile, :address))
          if user.student.profile
            user.student.profile.update(student_params[:profile])
          end
          if user.student.address
            user.student.address.update(student_params[:address])
          end
        end
    
        if user.save
          yield user if block_given?
          if user.active_for_authentication?
            set_flash_message! :notice, :updated
            bypass_sign_in(user, scope: resource_name)
            redirect_to after_update_path_for(user)
          else
            set_flash_message! :notice, :updated_but_must_reconfirm
            expire_data_after_sign_in!
            redirect_to after_update_path_for(user)
          end
        else
          clean_up_passwords user
          set_minimum_password_length
          flash[:alert] = "There was an error with your profile update. Please check the form for errors: #{user.student.errors.full_messages.to_sentence}"
          redirect_to edit_user_registration_path
        end
      else
        flash[:alert] = 'Invalid current password.'
        redirect_to edit_user_registration_path
      end
    else
      redirect_to root_path
    end
  end  

  def add_subject
    redirect_to root_path if current_user.role != 'Student' || !current_user.student.subject.nil?
  end
  
  def change_subject_request
    if current_user.role == 'Student'
      if current_user.valid_password?(params[:user][:current_password])
        subject_params = params[:user][:student][:subject]
        student = current_user.student
        if student.subject.nil?
          subject = Subject.create(name: subject_params[:name], student:  student)
          if subject.save
            redirect_to root_path, notice: 'Subject has been updated.'
          else
            flash[:alert] = 'Failed to update subject.'
            redirect_to add_subject_path
          end
        else
          flash[:alert] = 'You are already selected your subject.'
          redirect_to root_path
        end
      else
        flash[:alert] = 'Invalid current password.'
        redirect_to add_subject_path
      end
    else
      redirect_to root_path
    end
  end  

  def create
    generated_password = Devise.friendly_token.first(8)
    build_resource(sign_up_params.except(:student))
    resource.password = generated_password
    resource.password_confirmation = generated_password
    student_params = sign_up_params[:student]
    resource.build_student(student_params.except(:profile, :address))
    resource.student.build_profile(student_params[:profile])
    resource.student.build_address(student_params[:address])
    resource.student.verified = false
    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :updated_but_must_reconfirm
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      flash[:alert] = "There was an error with your registration. Please check the form for errors: #{resource.student.errors.full_messages.to_sentence}"
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email,
      student: [
        :name,
        profile: [:avatar, :bio, :dob, :gender],
        address: [:street, :city, :state, :pin]
      ]
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :current_password,
      student: [
        :name,
        profile: [:avatar, :bio, :dob, :gender],
        address: [:street, :city, :state, :pin]
      ]
    ])
  end

  def after_sign_up_path_for(resource)
    sign_out current_user
    root_path
  end
end

