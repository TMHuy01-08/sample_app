class UsersController < ApplicationController
  before_action :find_user, except: %i(index new create)
  before_action :logged_in_user, only: %i(index edit update destroy following followers)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @pagy, @users = pagy User.all, page: params[:page], items: Settings.paginate.limit
  end

  def new
    @user = User.new
  end

  def show
    @pagy, @microposts = pagy @user.microposts.newest, page: params[:page],
                                                        items: Settings.paginate.limit
    return if @user

    flash[:error] = t "not_found"
    redirect_to root_path
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_mail_activate
      flash[:info] = t ".mail_notice"
      redirect_to root_path
    else
      flash[:danger] = t ".users_unsuccess"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".update_success"
      redirect_to @user
    else
      flash[:danger] = t ".update_false"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".user_delete_fail"
    end
    redirect_to users_url
  end

  def following
    @title = t ".title_show_followers"
    @pagy, @users = pagy @user.followers
    render :show_follow
  end

  def followers
    @title = t ".title_show_following"
    @pagy, @users = pagy @user.followers
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    return if check_correct_user? @user

    flash[:danger] = t ".incorrect_user"
    redirect_to root_path
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t ".incorrect_admin"
    redirect_to root_path
  end
end
