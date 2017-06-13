class ScheduleParser
  class << self
    def parse(original, time_zone: 'UTC', target_date: nil)
      text = original
      text = text.gsub(/[\n\r]/, ' ')
      text = text.gsub(/(?<hour>\d{2})(?<minutes>\d{2})[ 　]*[-〜~]/, '\k<hour>:\k<minutes>')
      regexp = /(夜|午後|夕方)[ 　]*(\d{1,2})時(\d{1,2}分)?/
      if matches = text.match(regexp)
        hour = matches[2].to_i
        if hour < 12
          hour += 12
        end
        minutes = 0
        if matches.length > 3
          minutes = matches[3].to_i
        end
        text = text.gsub(regexp, format('%02d:%02d', hour, minutes))
      end
      text = text.gsub(/(?<hour>\d{2}):(?<minutes>\d{2})/, ' \k<hour>:\k<minutes> ')
      text = text.gsub(/(?<month>\d{1,2})\/(?<day>\d{1,2})/, '\k<month>月\k<day>日')

      schedule = {datetime: [], location: '', title: '', description: ''}
      response = {}
      GooApiWrapper.name_entity_extraction(text, time_zone: time_zone, target_date: target_date) do |item|
        key = item.keys.first
        response[key] = [] if response[key].blank?
        response[key] << item[key]
        response[key].uniq!
      end

      if response[:date].present? && response[:time].present?
        response[:time].length.times do |i|
          schedule[:datetime] << (response[:date][0].strftime('%F') + ' ' + response[:time][i].strftime('%T')).in_time_zone(time_zone)
        end
      end

      locations = []
      locations << response[:location] if response[:location].present?
      locations << response[:artifact] if response[:artifact].present?
      schedule[:location] = locations.flatten.uniq.join(' ')

      title_tmp = []
      title_tmp << response[:location] if response[:location].present?
      title_tmp << response[:artifact] if response[:artifact].present?
      title_tmp << response[:person] if response[:person].present?
      title_tmp << response[:organization] if response[:organization].present?
      mecab_results = MecabWrapper.parse(title_tmp.flatten.uniq.join(' '))

      title_tmp = []
      mecab_results.each do |word|
        title_tmp << word.word if word.wikipedia?
      end

      schedule[:title] = title_tmp.flatten.uniq.join(' ')
      schedule[:description] = original

      schedule
    end
  end
end
