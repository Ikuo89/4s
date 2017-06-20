class TaggerWrapper
  class << self
    def name_entity_extraction(text, time_zone: 'UTC', target_date: nil)
      target_date = Time.zone.now.in_time_zone(time_zone) if target_date.blank?

      Rails.logger.info "#{Settings.python.path} #{Rails.root}/tagger/tagger.py \"#{text.gsub(/["\n\r]/, '')}\""
      tagged = %x[#{Settings.python.path} #{Rails.root}/tagger/tagger.py "#{text.gsub(/["\n\r]/, '')}"]
      lines = tagged.split("\n")

      parsed = []
      tagged_text = nil
      pre_item = nil
      pre_flag = nil
      lines.each do |line|
        features = line.split("\t")
        if /(?<flag>(B|I))-(?<item>[A-Z]+)/ =~ features[-1]
          if flag == 'B'
            parsed << [pre_item, tagged_text] if tagged_text.present?
            tagged_text = features[0]
          elsif flag == 'I'
            tagged_text += features[0]
          end

          pre_flage = flag
          pre_item = item
        end
      end

      parsed << [pre_item, tagged_text] if tagged_text.present?
      parsed.each do |item|
        parsed_item = nil
        begin
          case item[0]
          when 'ART'
            parsed_item = {artifact: item[1]}
          when 'ORG'
            parsed_item = {organization: item[1]}
          when 'PSN'
            parsed_item = {person: item[1]}
          when 'LOC'
            parsed_item = {location: item[1]}
          when 'DAT'
            begin
              parsed_date = Date.parse2(item[1], time_zone: time_zone, target_date: target_date)
              parsed_item = {date: parsed_date} if parsed_date.present?
            rescue => e
            end
          when 'TIM'
            begin
              parsed_time = item[1].in_time_zone(time_zone)
              parsed_item = {time: parsed_time} if parsed_time.present?
            rescue => e
            end
          end
        rescue => e
          Rails.logger.warn e
        end

        yield parsed_item if parsed_item.present?
      end
    end
  end
end
