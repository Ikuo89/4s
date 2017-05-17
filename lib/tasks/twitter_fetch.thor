require 'thor/rails'
require './config/environment'

class TwitterFetch < Thor
  desc 'watch [twitter_id]', 'start watch process'
  def watch(twitter_id)
    BatchSerializer.run('-' + twitter_id) do
      twitter = TwitterWrapper.new
      twitter.stream([twitter_id]) do |text|
        p text
      end
    end
  end
end
