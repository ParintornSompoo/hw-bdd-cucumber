# frozen_string_literal: true

class Moviegoers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    moviegoer = Moviegoer.from_omniauth(auth) 
    if moviegoer.present?
      sign_out_all_scopes
      flash[:success]= t'devise.omniauth_callbacks.success',kind: 'Google'
      sign_in_and_redirect moviegoer,event: :authentication
    else
      flash['alert']=t'devise.omniauth_callbacks.failure',kind: 'Google',reason: 'User not found'
    end
  end

  protected
  def after_omniauth_failure_path_for(_scope)
    new_moviegoer_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || movies_path
  end

  private
  def auth 
    @auth ||= request.env['omniauth.auth']  
  end
end
