class TwitterService
  class << self
    def twitter_client
      @twitter = TwitterWrapper.new if @twitter.blank?
      @twitter
    end

    def user_search(query)
      self.twitter_client.user_search(query) do |user_hash|
        yield TwitterUser.parse(user_hash)
      end
    end
  end
end
