RSpec.describe User do
  it { should define_enum_for(:role).with_values(member: 0, moderator: 10, admin: 20) }
end
