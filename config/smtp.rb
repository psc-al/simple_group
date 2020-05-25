SMTP_SETTINGS = {
  address: ENV.fetch('SMTP_ADDRESS'),
  authentication: :login,
  enable_starttls_auto: true,
  password: ENV.fetch('SMTP_PASSWORD'),
  port: '587',
  user_name: ENV.fetch('SMTP_USERNAME')
}.freeze
