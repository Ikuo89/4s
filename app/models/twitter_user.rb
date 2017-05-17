class TwitterUser < ApplicationRecord
  default_scope ->{ where(deleted: 0) }

  def parsed_data
    JSON.parse(data, {:symbolize_names => true})
  end

  def screen_name
    parsed_data[:screen_name]
  end

  def name
    parsed_data[:name]
  end

  def time_zone
    parsed_data[:time_zone]
  end

  def utc_offset
    parsed_data[:utc_offset]
  end

  def profile_image_url_https
    parsed_data[:profile_image_url_https]
  end

  def to_h
    {
      id: id,
      twitter_com_user_id: twitter_com_user_id,
      screen_name: screen_name,
      name: name,
      time_zone: time_zone,
      utc_offset: utc_offset,
      profile_image_url_https: profile_image_url_https,
    }
  end

  class << self
    def insert_or_update!(hash_item)
      model = self.find_by(twitter_com_user_id: hash_item[:id], deleted: 0)
      if model.present?
        model.data = JSON.generate(hash_item)
      else
        model = self.new(
          twitter_com_user_id: hash_item[:id],
          data: JSON.generate(hash_item),
        )
      end

      model.save!
      model
    end
  end
end
