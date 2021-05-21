class UserController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  def create
    event = Events::User::Created.create(payload: user_params)

    render json: event.user
  end

  def destroy
    event = Events::User::Destroyed.create(user_id: user_params[:id], payload: user_params)

    render json: event.user
  end

  private def user_params
    params.require(:user).permit(:name, :email, :password, :id)
  end
end
