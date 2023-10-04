class StudentVerificationMailer < ApplicationMailer
    def send_temp_password(user, temp_password)
      @student = user.student.name
      @temp_password = temp_password
      subject = "Congratulations! #{@student} Your Account is Verified"
      mail(to: user.email, subject: subject)
    end
  end
  
