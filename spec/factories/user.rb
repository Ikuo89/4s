FactoryGirl.define do
  tmp_salt = Encryptor.generate_salt
  factory :user do
    sequence(:email) {|n| "#{n}#{Faker::Internet.email}" }
    image Faker::Avatar.image
    encrypted_token Encryptor.encrypt(Faker::Internet.password, tmp_salt)
    encrypted_refresh_token Encryptor.encrypt(Faker::Internet.password, tmp_salt)
    salt tmp_salt
  end
end
