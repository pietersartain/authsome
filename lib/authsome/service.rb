
class AuthsomeService

  # This doesn't remove the auth on the application,
  # just removes the token from the local store.
  def deauth(user)
    close
    @data.hdel(@service,"atoken_"<<user)
  end

  def authorized?
    return !@atoken.nil?
  end

  def close
    @atoken = nil
  end

end
