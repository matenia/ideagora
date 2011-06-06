class WelcomeController < ApplicationController
  def index
    @todays_talks = Camp.current.talks.for_day( params[:day].try(:to_date) || Time.now.to_date )
    @latest_notice = Camp.current.notices.last
  end
end
