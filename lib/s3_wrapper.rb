require 'aws-sdk'
class S3Wrapper
  class << self
    def upload(key, file_path)
      Aws.config.update(region: Settings[:aws][:s3][:region], credentials: Aws::Credentials.new(Settings[:aws][:user][:accesskey], Settings[:aws][:user][:secret]))
      s3 = Aws::S3::Resource.new
      obj = s3.bucket(Settings[:aws][:s3][:bucket_name]).object(key)
      obj.upload_file(file_path)
    end

    def download(key, file_path)
      Aws.config.update(region: Settings[:aws][:s3][:region], credentials: Aws::Credentials.new(Settings[:aws][:user][:accesskey], Settings[:aws][:user][:secret]))
      s3 = Aws::S3::Client.new
      File.open(file_path, 'wb') do |file|
        s3.get_object(bucket: Settings[:aws][:s3][:bucket_name], key: key) do |chunk|
          file.write(chunk)
        end
      end
    end
  end
end
