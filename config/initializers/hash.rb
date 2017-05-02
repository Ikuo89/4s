require 'active_support/core_ext'

class Hash
  unless method_defined?(:camelize_keys)
    def camelize_keys(first_letter = :upper)
      transform_keys { |key| key.to_s.camelize(first_letter) rescue key }
    end
  end

  unless method_defined?(:camelize_keys!)
    def camelize_keys!(first_letter = :upper)
      transform_keys! { |key| key.to_s.camelize(first_letter) rescue key }
    end
  end
end
