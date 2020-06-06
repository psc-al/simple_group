class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_SENDER_EMAIL")
  layout 'mailer'
end
