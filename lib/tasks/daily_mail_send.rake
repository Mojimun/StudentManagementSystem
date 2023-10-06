desc "daily good morning mail send"
task daily_mail_send: [:environment] do
    users = User.includes(:student).where.not(role: "Admin")
    recipients = users.map { |x| { email: x.email, name: x.student&.name } }
    recipients.each do |user|
      subject = "Good Morning, #{user[:name]}!"
      message = "Dear #{user[:name]},\n\nI hope you have a wonderful day ahead!\n\nBest regards,\nThe Student Registration Team"
      StudentVerificationMailer.send_mail(user[:email], subject, message).deliver
    end
end
  