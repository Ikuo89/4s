set :output, 'log/crontab.log'
job_type :thor, "cd :path && :environment_variable=:environment bundle exec thor :task :output"

if @environment == 'production'
  every 1.hours, :roles => [:job] do
    thor "calendar_sync:fetch"
  end

  every 30.minutes, :roles => [:job] do
    thor "twitter_fetch:fetch"
  end
end
