class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @props = { accountName: current_user.email, initialStep: 0 }
  end
end
