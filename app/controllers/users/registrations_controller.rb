# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [:new, :create]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end
  def change_password
    redirect_to dashboard_path if current_user.role != 'Student'
  end

  def change_my_password
    if current_user.role == 'Student'
      if current_user.valid_password?(params[:user][:current_password])
        if current_user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation], reset_password_token: params[:user][:authenticity_token])
          bypass_sign_in(current_user) 
          sign_out current_user
          redirect_to root_path, notice: 'Your password has been changed.'
        else
          redirect_to change_password_path
        end
      else
        flash[:alert] = 'Invalid current password.'
        redirect_to change_password_path
      end
    else 
      redirect_to dashboard_path
    end
  end
  
  # POST /resource
  # def create
  #   super
  # end
  
  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
