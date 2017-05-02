class Date
  class << self
    def parse2(text)
      if text =~ /(きょう|今日)/
        return Date.today
      elsif text =~ /(あした|明日)/
        return Date.today + 1
      end

      begin
        return Date.parse(text)
      rescue ArgumentError
        formats = ['%Y年%m月%d日', '%m月%d日']
        formats.each do |format|
          begin
            return Date.strptime(text, format)
          rescue ArgumentError
          end
        end
      end
    end
  end
end
