class Encryptor
  APP_SECRET = Settings[:app][:secret]
  class << self
    def app_secret
      APP_SECRET
    end

    def generate_salt(length = 16)
      SecureRandom::hex(length)
    end

    def encrypt(value, secret)
      encryptor = ::ActiveSupport::MessageEncryptor.new((APP_SECRET + secret)[0..31], cipher: 'aes-256-cbc')
      encryptor.encrypt_and_sign(value)
    end

    def decrypt(value, secret)
      begin
        encryptor = ::ActiveSupport::MessageEncryptor.new((APP_SECRET + secret)[0..31], cipher: 'aes-256-cbc')
        return encryptor.decrypt_and_verify(value)
      rescue
        return nil
      end
    end
  end
end
