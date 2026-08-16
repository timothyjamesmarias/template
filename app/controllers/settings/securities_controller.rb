module Settings
  class SecuritiesController < BaseController
    def show
      @user = current_user
    end
  end
end
