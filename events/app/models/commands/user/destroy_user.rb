class Commands::User::DestroyUser
  payload_attributes :id

  def apply(user)
    user.deleted = true

    user
  end

  def noop?
    user.deleted?
  end
end
