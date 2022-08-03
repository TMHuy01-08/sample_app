class UsersController < ApplicationController
  before_action :find_user, except: %i(index new create)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @pagy, @users = pagy User.all, page: params[:page], items: Settings.paginate.limit
  end

  def new
    @user = User.new
  end

  def show
    return if @user

    flash[:error] = t "not_found"
    redirect_to root_path
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "success_signup"
      redirect_to @user
    else
      flash[:error] = t "fail_signup"
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
    if user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".user_delete_fail"
    end
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user.present?

    flash[:danger] = t ".not_found"
    redirect_to signup_path
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".danger"
    redirect_to login_path
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
