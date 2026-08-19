class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      id: @user.id,
      email: @user.email,
      name: @user.name,
      provider: @user.provider,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }
  end
end