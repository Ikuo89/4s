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

    def create(twitter_com_user_id)
      user_hash = self.twitter_client.user(twitter_com_user_id)
      raise TwitterUserNotFoundError if user_hash.blank?

      twitter_user = TwitterUser.insert_or_update!(user_hash)
    end
  end
end
class TwitterUserNotFoundError < StandardError; end
