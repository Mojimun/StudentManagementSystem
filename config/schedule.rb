set :environment, 'development'

every 1.day, at: '8:00 am' do
  rake 'daily_mail_send'
  rake 'birthday_mail_send'
end
