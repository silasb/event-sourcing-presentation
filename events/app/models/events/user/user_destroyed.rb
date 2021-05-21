class Events::User::UserDestroyed < Events::User::BaseEvent
  payload_attributes :id

  def apply(user)
    user.deleted = true

    user
  end
end
