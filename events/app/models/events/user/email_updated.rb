class Events::User::EmailUpdated < Events::User::BaseEvent
  payload_attributes :email

  def apply(user)
    user.email = email

    user
  end
end
