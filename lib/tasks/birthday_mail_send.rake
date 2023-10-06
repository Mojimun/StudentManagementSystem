require 'date'

desc "send happy birthday"
task birthday_mail_send: [:environment] do
  users = User.includes(student: [:profile]).where.not(role: "Admin")
  recipients = users.map { |x| { email: x.email, name: x.student&.name, dob: x.student.profile&.dob } }
  current_date = Date.today
  recipients.each do |user|
    user_dob = user[:dob]
    if user_dob && user_dob.strftime("%m-%d") == current_date.strftime("%m-%d")
      subject = "Happy Birthday, #{user[:name]}!"
      message = "Dear #{user[:name]},\n\nWishing you a fantastic birthday filled with joy and happiness!\n\nBest regards,\nThe Student Registration Team"
      StudentVerificationMailer.send_mail(user[:email], subject, message).deliver
    end
  end
end
