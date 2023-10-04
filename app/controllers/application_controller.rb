class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    
    def dashboard
        if current_user
            if current_user.role == "Admin"
                redirect_to admin_home_path
            elsif current_user.role == "Student"
                if (current_user.sign_in_count == 2)
                  redirect_to change_password_path
                else
                    if current_user.student.subject.nil?
                        redirect_to add_subject_path
                    else
                        redirect_to student_home_path
                    end
                end
            end
        else
            redirect_to new_user_session_path
        end
    end

end
