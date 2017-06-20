class MecabWord
  def initialize(word, features)
    @word = word
    @features = features
  end

  def word
    @word
  end

  def noun?
    @features[0] == '名詞'
  end

  def proper_noun?
    @features[1] == '固有名詞'
  end

  def wikipedia?
    @features.include?('wikipedia')
  end

  def prefix?
    @features[0] == '接頭詞' && /(名詞|数)接続/ === @features[1]
  end

  def postfix?
    self.noun? && @features[1] == '接尾'
  end

  def digit?
    self.noun? && @features[1] == '数'
  end

  def adjective?
    @features[0] == '形容詞'
  end

  def combine?(other)
    (self.prefix? && other.noun?) ||
    (self.noun? && other.postfix?) ||
    (self.digit? && other.digit?)
  end
end
