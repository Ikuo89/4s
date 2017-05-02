class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable
  has_many :user_calendars_relations
  has_many :calendars, through: :user_calendars_relations
  default_scope ->{ where(deleted: 0) }

  def token
    Encryptor.decrypt(self.encrypted_token, self.salt)
  end

  def token=(value)
    self.encrypted_token = Encryptor.encrypt(value, self.salt)
  end

  def refresh_token
    Encryptor.decrypt(self.encrypted_refresh_token, self.salt)
  end

  def refresh_token=(value)
    self.encrypted_refresh_token = Encryptor.encrypt(value, self.salt)
  end

  def generate_token
    expire_time = (Time.zone.now + (30 * 24 * 60 * 60)).strftime('%Y-%m-%dT%H:%M:%SZ')
    Encryptor.encrypt(expire_time + ',' + self.email, Encryptor.app_secret)
  end

  def update_credentials!(token, refresh_token)
    self.token = token
    self.refresh_token = refresh_token
    self.save!
  end

  def identifier
    Encryptor.encrypt(self.email, Encryptor.app_secret)
  end

  class << self
    def insert!(email, image, token, refresh_token)
      user = User.new(email: email, image: image, salt: Encryptor.generate_salt)
      user.token = token
      user.refresh_token = refresh_token
      user.save!
      user
    end

    def parse_token(token)
      decrypted = Encryptor.decrypt(token, Encryptor.app_secret)
      if decrypted == nil
        return nil
      end

      decrypted_ary = decrypted.split(',')
      if decrypted_ary.length != 2
        return nil
      end

      expire_time = Time.strptime(decrypted_ary[0], '%Y-%m-%dT%H:%M:%SZ')
      email = decrypted_ary[1]

      if expire_time < Time.zone.now
        return nil
      end

      self.find_by(email: email)
    end

    def analyze_identifier(identifier)
      email = Encryptor.decrypt(identifier, Encryptor.app_secret)
      if email == nil
        return nil
      end

      self.find_by(email: email)
    end
  end
end
