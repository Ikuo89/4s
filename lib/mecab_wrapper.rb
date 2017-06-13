require 'natto'
class MecabWrapper
  class << self
    def natto_mecab
      @natto_mecab = Natto::MeCab.new(dicdir: Settings[:mecab][:neologd], userdic: Settings[:mecab][:userdic]) unless @natto_mecab
      @natto_mecab
    end

    def parse(str)
      keywords = []
      self.natto_mecab.parse(str.encode("utf-8", "utf-8-mac")) do |n|
        begin
          unless n.feature.start_with?('BOS/EOS')
            features = n.feature.split(',')
            keywords.push(MecabWord.new(n.surface, features))
          end
        rescue => e
          p e
          raise e
        end
      end
      keywords
    end
  end
end
