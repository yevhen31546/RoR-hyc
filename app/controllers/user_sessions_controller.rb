class UserSessionsController < ApplicationController
  skip_after_filter :store_location

  def new
    if logged_in?
      redirect_back_or_default account_path; return
    end
    if User.count == 0
      flash[:notice] = 'No users in the system, please sign up'
      redirect_to signup_path; return
    end

    @user_session = UserSession.new
    if cookies.blank?
      flash[:error] = 'Cookies must be enabled'  # note Internet Explorer will not store cookies for hostnames with underscores
      return
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if params[:user_session]['password'] == 'password' && Rails.env.production?
        flash[:notice] = 'Please change your password'
        redirect_to :controller => '/account', :action => 'edit'; return
      end
      flash[:success] = 'Login successful!'
      redirect_back_or_default account_path; return
    else
      render :action => :new; return
    end
  end

  def destroy
    current_user_session.try(:destroy)
    @user_session = nil
    flash[:notice] = 'You have been logged out'
    redirect_back_or_default login_path; return
  end

  private 
  def use_https?
    true
  end
end
