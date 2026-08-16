module Settings
  class BaseController < ApplicationController
    before_action :authenticate_user!

    layout "settings"
  end
end
