require 'nkf'
class String
  def utf8mb4_encode(encoded = '?')
    return self.scrub(encoded).gsub(/[^\u{0}-\u{FFFF}]/,encoded)
  end
  def utf8_json_escape
    return self.gsub(/[\\]+u0026/,'&').gsub(/[\\]+u[0-9a-fA-F]{4}/,'').gsub(/\\\\/,'').gsub(/\\[a-zA-Z]/,'').gsub('￿','')
  end
  def lucene_escape
    return self.gsub(/[\\\[\]\{\}\(\)\/\*\+\^'":~]/,'').gsub(/(&&|\|\|)/,'')
  end
  def camel_to_sneak
    sneak = self
    self.scan(/(["'][^"']+["'])\s*:[^,{}]+/) { |word|
        sneak_word = word[0].gsub(/([a-z])([A-Z])([a-z])/,'\1_\2\3').downcase
        sneak = sneak.gsub(word[0], sneak_word)
    }
    return sneak
  end
  def convert
    str = self
    str = str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
    str = NKF.nkf('-w -W -X', str)
  end
  def is_url?
    if /https?:\/\/[\w\/:%#$&?()~.=+-]+/ =~ self
      return true
    else
      return false
    end
  end
  def is_email?
    if /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i =~ self
      return true
    else
      return false
    end
  end
  def append_query(append = {})
    base = self
    query = {}
    hash = ''
    self.scan(/^(?:(https?:)?(?:\/\/(([^\/:?#]+)(?::([0-9]+))?)))?(\/?[^?#]*)\??([^?#]*)#?(.*)/) { |parts|
      base = ''
      base += parts[0] if parts[0]
      base += '//' + parts[1] if parts[1]
      base += parts[4] if parts[4]
      query = Hash[URI.decode_www_form(parts[5])]
      hash = parts[6]
    }

    append.each {|key, value|
      if value
        query[key.to_s] = value
      else
        query.delete(key.to_s)
      end
    }
    return base += '?' + URI.encode_www_form(query) + (hash == '' ? '' : '#' + hash)
  end
  def to_bool
    return self if self.class.kind_of?(TrueClass) || self.class.kind_of?(FalseClass)

    if self.downcase =~ /^(true|false)$/
      return true if $1 == 'true'
      return false if $1 == 'false'
    else
      raise NoMethodError.new("undefined method `to_bool' for '#{self}'")
    end
  end
  def is_iso639_1?
    iso_639_1 = ['-', 'unknown', 'aa','af','ak','sq','am','ar','an','hy','as','av','ae','ay','az','bm','ba','eu','be','bn','bh','bi','bs','br','bg','my','ca','ch','ce','ny','zh','cv','kw','co','cr','hr','cs','da','dv','nl','dz','en','eo','et','ee','fo','fj','fi','fr','ff','gl','ka','de','el','gn','gu','ht','ha','he','hz','hi','ho','hu','ia','id','ie','ga','ig','ik','io','is','it','iu','ja','jv','kl','kn','kr','ks','kk','km','ki','rw','ky','kv','kg','ko','ku','kj','la','lb','lg','li','ln','lo','lt','lu','lv','gv','mk','mg','ms','ml','mt','mi','mr','mh','mn','na','nv','nb','nd','ne','ng','nn','no','ii','nr','oc','oj','cu','om','or','os','pa','pi','fa','pl','ps','pt','qu','rm','rn','ro','ru','sa','sc','sd','se','sm','sg','sr','gd','sn','si','sk','sl','so','st','es','su','sw','ss','sv','ta','te','tg','th','ti','bo','tk','tl','tn','to','tr','ts','tt','tw','ty','ug','uk','ur','uz','ve','vi','vo','wa','cy','wo','fy','xh','yi','yo','za','zu']
    iso_639_1.include?(self.downcase)
  end
  def is_iso3166_1_alpha_2?
    iso3166_1_alpha_2 = ['-', 'UNKNOWN', 'AD','AE','AF','AG','AI','AL','AM','AO','AQ','AR','AS','AT','AU','AW','AX','AZ','BA','BB','BD','BE','BF','BG','BH','BI','BJ','BL','BM','BN','BO','BQ','BR','BS','BT','BV','BW','BY','BZ','CA','CC','CD','CF','CG','CH','CI','CK','CL','CM','CN','CO','CR','CU','CV','CW','CX','CY','CZ','DE','DJ','DK','DM','DO','DZ','EC','EE','EG','EH','ER','ES','ET','FI','FJ','FK','FM','FO','FR','GA','GB','GD','GE','GF','GG','GH','GI','GL','GM','GN','GP','GQ','GR','GS','GT','GU','GW','GY','HK','HM','HN','HR','HT','HU','ID','IE','IL','IM','IN','IO','IQ','IR','IS','IT','JE','JM','JO','JP','KE','KG','KH','KI','KM','KN','KP','KR','KW','KY','KZ','LA','LB','LC','LI','LK','LR','LS','LT','LU','LV','LY','MA','MC','MD','ME','MF','MG','MH','MK','ML','MM','MN','MO','MP','MQ','MR','MS','MT','MU','MV','MW','MX','MY','MZ','NA','NC','NE','NF','NG','NI','NL','NO','NP','NR','NU','NZ','OM','PA','PE','PF','PG','PH','PK','PL','PM','PN','PR','PS','PT','PW','PY','QA','RE','RO','RS','RU','RW','SA','SB','SC','SD','SE','SG','SH','SI','SJ','SK','SL','SM','SN','SO','SR','SS','ST','SV','SX','SY','SZ','TC','TD','TF','TG','TH','TJ','TK','TL','TM','TN','TO','TR','TT','TV','TW','TZ','UA','UG','UM','US','UY','UZ','VA','VC','VE','VG','VI','VN','VU','WF','WS','YE','YT','ZA','ZM','ZW']
    iso3166_1_alpha_2.include?(self.upcase)
  end
end
