class GooApiWrapper
  class << self
    MAX_RETRY_COUNT = 5
    def name_entity_extraction(text, time_zone: 'UTC', target_date: nil)
      target_date = Time.zone.now.in_time_zone(time_zone) if target_date.blank?
      Rails.logger.debug "call: 'https://labs.goo.ne.jp/api/entity' value: #{text}"

      result = call_query('https://labs.goo.ne.jp/api/entity', {
        app_id: app_id,
        request_id: SecureRandom::hex(12),
        sentence: text,
      })

      Rails.logger.debug result
      if result && result[:ne_list].present?
        result[:ne_list].each do |item|
          parsed_item = nil
          begin
            case item[1]
            when 'ART'
              parsed_item = {artifact: item[0]}
            when 'ORG'
              parsed_item = {organization: item[0]}
            when 'PSN'
              parsed_item = {person: item[0]}
            when 'LOC'
              parsed_item = {location: item[0]}
            when 'DAT'
              parsed_item = {date: Date.parse2(item[0], time_zone: time_zone, target_date: target_date)}
            when 'TIM'
              parsed_item = {time: item[0].in_time_zone(time_zone)}
            end
          rescue => e
            Rails.logger.warn e
          end

          yield parsed_item if parsed_item.present?
        end
      end
    end

    private
    def app_id
      Settings.goo.app_id
    end

    def call_query(url, form_data)
      retry_count = 0

      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)

      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)

      req['Content-type'] = 'application/json'
      req['Accept'] = 'application/json'
      req.set_form_data(form_data)
      Rails.logger.debug url
      Rails.logger.debug form_data

      begin
        res = https.request(req)

        status_code = res.code.to_i
        if status_code >= 200 && status_code < 300
          return JSON.parse(res.body, {:symbolize_names => true})
        elsif status_code == 404
          raise PageNotFound.new("#{res.code} #{res.message}")
        elsif status_code == 429 || status_code == 403
          raise TooManyRequestError.new("#{res.code} #{res.message}")
        else
          raise HttpError.new("#{res.code} #{res.message}")
        end
      rescue => e
        if e.kind_of?(PageNotFound) || e.kind_of?(TooManyRequestError)
          raise e
        else
          if retry_count < MAX_RETRY_COUNT
            Rails.logger.warn e
            retry_count += 1
            retry
          else
            raise e
          end
        end
      end
    end
  end
end
