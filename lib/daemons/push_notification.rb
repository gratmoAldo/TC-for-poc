#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development" # "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  # ActiveRecord::Base.logger.info "This daemon is still running at #{Time.now}.\n"
  APN::App.send_notifications
  
  sleep 10
end
ActiveRecord::Base.logger.info "push_notification daemon stopped"
