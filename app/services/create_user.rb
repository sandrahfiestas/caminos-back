class CreateUser
  prepend Service::Base
  include Service::Support::User

  def initialize(allowed_params, roles_params)
    @allowed_params = allowed_params
    @roles = roles_params[:roles].to_h
  end

  def call
    create_user
  end

  def reload_user_params
    {
      username: @allowed_params[:username],
      email: @allowed_params[:email],
      password: @allowed_params[:password],
      active: true,
      approved: true,
      confirmed: true,
      roles: roles(@roles)
    }.tap do |_hash|
      _hash[:entity] = related_entity
    end
  end

  private

  def create_user

    @user = User.new(user_params)
    @user.profile = Profile.new(profile_params)

    return @user if @user.save

    errors.add_multiple_errors(@user.errors.messages) && nil
  end

  def user_params
    {
      username: @allowed_params[:username],
      email: @allowed_params[:email],
      password: @allowed_params[:password],
      active: true,
      approved: true,
      confirmed: true,
      roles: roles(@roles)
    }.tap do |_hash|
      _hash[:entity] = related_entity
    end
  end

  def related_entity
    return Organization.first if roles(@roles)[0] == 'admin' || roles(@roles)[0] == :admin
    @related_entity ||= if id = @allowed_params[:neighborhood_id]
      Neighborhood.find_by(id:id)
    end
  end

  def profile_params
    @allowed_params.delete('profile') || {}
  end

end
