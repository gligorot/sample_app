class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update] 
  #before actions edit/update run logged_in/correct_user methods
  before_action :admin_user,     only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url unless @user.activated? #they had a "and return unless ..." ?
    #why was there a "and return" ? (listing 11.40) -stackoverflow> NOT NEEDED
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		@user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
  		redirect_to root_url
  	else
  		render :new
  	end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

	  def user_params
	  	params.require(:user).permit(:name, :email, :password,
	  															 :password_confirmation)
	  end

    #Before filters

    #Confirms a logged-in user
    #def logged_in_user >>>MOVED TO APP CONTROLLER

    #Confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    #Confirms current user is admin
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
