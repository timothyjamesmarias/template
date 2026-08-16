module Settings
  class ProfilesController < BaseController
    def show
      @user = current_user
    end
  end
end
