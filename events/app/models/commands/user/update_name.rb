class Commands::User::UpdateName
  payload_attributes :name

  def apply(user)
    user.name = name

    user
  end
end
