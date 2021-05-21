class Commands::User::UpdateEmail
  payload_attributes :email

  def apply(user)
    user.email = email

    user
  end
end
