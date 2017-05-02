Dir["#{Rails.root}/lib/exceptions/*.rb"].each {|file| require file }
Dir["#{Rails.root}/lib/*.rb"].each {|file| require file }
Dir["#{Rails.root}/app/services/concerns/*.rb"].each {|file| require file }
Dir["#{Rails.root}/app/services/*.rb"].each {|file| require file }
