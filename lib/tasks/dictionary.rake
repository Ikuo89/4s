require 'open-uri'
require 'zlib'
require 'csv'
require 'fileutils'
namespace :dictionary do

  task update: :environment do
    download_path = 'https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-all-titles-in-ns0.gz'

    dir = "#{Rails.root}/tmp/dictionary_manage/"
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    downloaded_path = dir + File.basename(download_path)
    File.delete(downloaded_path) if File.exist?(downloaded_path)

    expanded_path = downloaded_path + '.csv'
    File.delete(expanded_path) if File.exist?(expanded_path)

    begin
      open(downloaded_path, 'wb') do |output|
        open(download_path) do |data|
          output.write(data.read)
        end
      end

      open(expanded_path, 'wb') do |output|
        Zlib::GzipReader.open(downloaded_path) do |gz|
          output.write(gz.read)
        end
      end

      # open(expanded_path).each do |title|
      #   title.strip!
      #
      #   next if title.length < 2
      #   next if title =~ %r(^[+-.$()?*/&%!"'_,]+)
      #   next if title =~ /^[-.0-9]+$/
      #   next if title =~ /曖昧さ回避/
      #   next if title =~ /_\(/
      #   next if title =~ /^PJ:/
      #   next if title =~ /の登場人物/
      #   next if title =~ /一覧/
      #   next if title =~ /^(\p{Hiragana}|\p{Katakana})$/
      #
      #   DictionaryWord.bulk_insert_pool(title.gsub('_', ' '))
      #   if DictionaryWord.bulk_insert_items_count > 10000
      #     DictionaryWord.bulk_insert_execute
      #   end
      # end

      # DictionaryWord.bulk_insert_execute

      CSV.open("#{dir}custom.csv", 'w') do |csv|
        open(expanded_path).each do |title|
          title.strip!

          next if title =~ %r(^[+-.$()?*/&%!"'_,]+)
          next if title =~ /^[-.0-9]+$/
          next if title =~ /曖昧さ回避/
          next if title =~ /_\(/
          next if title =~ /^PJ:/
          next if title =~ /の登場人物/
          next if title =~ /一覧/

          title_length = title.length

          if title_length > 3
            score = [-36000.0, -400 * (title_length ** 1.5)].max.to_i
            csv << [title, nil, nil, score, '名詞', '一般', '*', '*', '*', '*', title, '*', '*', 'wikipedia']
          end
        end
      end

      %x(#{Settings.mecab.mecab_dict_index_path} -d #{Settings.mecab.ipadic_path} -u #{Settings[:mecab][:userdic]} -f utf-8 -t utf-8 #{dir}custom.csv)

    rescue => e
      Rails.logger.error e
    ensure
      File.delete(downloaded_path) if File.exist?(downloaded_path)
      File.delete(expanded_path) if File.exist?(expanded_path)
    end
  end
end
