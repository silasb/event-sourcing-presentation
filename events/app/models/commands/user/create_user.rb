class Commands::User::CreateUser
  include Commands::Command
  attributes :name, :email, :password

  validates :name, presence: true 

  private def build_event
    Events::User::UserCreated.new(
      name: name,
      email: email,
      password: password,
    )
  end
end
