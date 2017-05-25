require 'thor/rails'
require './config/environment'

class TwitterFetch < Thor
  desc 'watch', 'start watch process'
  def watch
    BatchSerializer.run do
      TwitterService.watch_user_timeline
    end
  end

  desc 'fetch', 'start fetch'
  def fetch
    TwitterService.fetch_user_timeline
  end

  desc 'search', 'start fetch'
  def search
    
  end
end
