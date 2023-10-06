class StudentVerificationMailer < ApplicationMailer
    def send_temp_password(user, temp_password)
      @student = user.student.name
      @temp_password = temp_password
      subject = "Congratulations! #{@student} Your Account is Verified"
      mail(to: user.email, subject: subject)
    end

    def send_mail(user_email, subject, message)
      mail(to: user_email, body: message, subject: subject, content_type: "text/html")
    end
  end
  
