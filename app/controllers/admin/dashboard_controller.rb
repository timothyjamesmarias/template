module Admin
  class DashboardController < BaseController
    def show
      @user_count = User.count
      @admin_count = User.where(admin: true).count
      @unconfirmed_count = User.where(confirmed_at: nil).count
    end
  end
end
