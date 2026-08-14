class DashboardController < ApplicationController
  def show
    @props = { accountName: "Acme Inc", initialStep: 0 }
  end
end
