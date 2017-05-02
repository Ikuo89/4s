class ScheduleParser
  class << self
    def parse(original)
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
      GooApiWrapper.name_entity_extraction(text) do |item|
        key = item.keys.first
        response[key] = [] if response[key].blank?
        response[key] << item[key]
        response[key].uniq!
      end

      if response[:date].present? && response[:time].present?
        response[:time].length.times do |i|
          schedule[:datetime] << Time.parse(response[:date][0].strftime('%F') + ' ' + (response[:time][i] - 9.hours).strftime('%T'))
        end
      elsif response[:date].present?
        schedule[:datetime] << Time.parse(response[:date][0].strftime('%F'))
      end

      locations = []
      locations << response[:location] if response[:location].present?
      locations << response[:artifact] if response[:artifact].present?
      schedule[:location] = locations.flatten.uniq.join(' ')

      title = []
      title << response[:location] if response[:location].present?
      title << response[:artifact] if response[:artifact].present?
      title << response[:person] if response[:person].present?
      title << response[:organization] if response[:organization].present?
      schedule[:title] = title.flatten.uniq.join(' ')
      schedule[:description] = original

      schedule
    end
  end
end
