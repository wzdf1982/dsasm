class HomeController < ApplicationController
  skip_before_action :require_login, only: [:login, :register]
  def index
  end

  def login
  end

  def register
    if !User.where(name: params['UserCode']).empty? || User.new(name: params['UserCode']).save
      session[:user] = params['UserCode']
    end

    redirect_to root_url
  end

  def logout
    session[:user] = nil
    redirect_to :login
  end
end