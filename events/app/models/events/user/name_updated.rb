class Events::User::NameUpdated < Events::User::BaseEvent
  payload_attributes :name

  def apply(user)
    user.name = name

    user
  end
end
