# encoding: utf-8

class ProfileController < ApplicationController
  before_filter :authenticate
  before_filter :redirect_restricted_users

  def index
    @user = current_user
  end

  def update
    old_current_user = current_user.dup
    @user = current_user

    @user.attributes = user_params
    @user.password = params[:password] unless params[:password].blank?

    if @user.save
      session[:username] = @user.username

      # Update the remember_me cookie
      if cookies.signed[:remember_me]
        if cookies.signed[:remember_me].first == current_user.username
          salt = BCrypt::Password.new(@user.password_digest).salt

          cookies.signed[:remember_me] = {
            :value => [current_user.username, salt],
            :expires => 2.weeks.from_now.utc
          }
        end
      end

      redirect_to profile_path, :notice => "Your profile has been updated."
    else
      @current_user = old_current_user
      flash[:error] = "There was an error updating your profile."
      render :index
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :name, :distance_units)
  end

  def redirect_restricted_users
    redirect_to dashboard_path if current_user.is_restricted?
  end
end
