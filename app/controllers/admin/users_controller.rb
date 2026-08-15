module Admin
  class UsersController < BaseController
    def index
      @users = User.order(created_at: :desc).limit(100)
    end

    def show
      @user = User.find(params[:id])
    end
  end
end
