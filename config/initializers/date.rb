class Date
  class << self
    def parse2(text, time_zone: 'UTC', target_date: nil)
      target_date = target_date.in_time_zone(time_zone) if target_date.blank?
      if text =~ /(きょう|今日)/
        return target_date
      elsif text =~ /(あした|明日)/
        return target_date + 1.day
      end

      begin
        return Date.parse(text).in_time_zone(time_zone)
      rescue ArgumentError
        formats = ['%Y年%m月%d日', '%m月%d日', '%Y/%m/%d', '%m/%d']
        formats.each do |format|
          begin
            return Date.strptime(text, format).in_time_zone(time_zone)
          rescue ArgumentError
          end
        end
      end
    end
  end
end
