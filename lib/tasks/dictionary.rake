require 'open-uri'
require 'zlib'
require 'csv'
require 'fileutils'

namespace :dictionary do
  task update: :environment do
    download_path = 'https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-all-titles-in-ns0.gz'

    dir = "#{Rails.root}/tmp/dictionary/"
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

      S3Wrapper.download('municipality.csv', "#{dir}municipality.csv")
      csv_text = File.read("#{dir}municipality.csv", encoding: 'utf-8')
      csv_text = csv_text.gsub(/\r\n/, "\n")
      municipality_data = CSV.parse(csv_text, skip_blanks: true)

      S3Wrapper.download('eki.txt', "#{dir}eki.txt")
      eki_data = File.read("#{dir}eki.txt")

      CSV.open("#{dir}custom.csv", 'w') do |csv|
        open(expanded_path).each do |title|
          title.strip!
          title = title.gsub(/[!?]/, '')

          next if title.length < 4
          next if title =~ %r(^[+-.$()?*/&%!"'_,]+)
          next if title =~ /^[-.:a-zA-Z0-9]+$/
          next if title =~ /曖昧さ回避/
          next if title =~ /_\(/
          next if title =~ /^PJ:/
          next if title =~ /の登場人物/
          next if title =~ /一覧/
          next if title =~ /月.+日/
          next if title =~ /^(\p{Hiragana}|\p{Katakana})$/

          title_length = title.length
          score = [-36000.0, -400 * (title_length ** 1.5)].max.to_i
          csv << [title, nil, nil, score, '名詞', '一般', '*', '*', '*', '*', title, '*', '*', 'wikipedia']
        end

        municipality_data.each do |municipality_item|
          if municipality_item[2].present?
            word = municipality_item[2]
          else
            word = municipality_item[1]
          end

          word_length = word.length
          score = [-36000.0, -400 * (word_length ** 1.5)].max.to_i
          csv << [word, nil, nil, score, '名詞', '固有名詞', '地域', '一般', '*', '*', word, '*', '*', 'municipality']
        end

        eki_data.split("\n").each do |eki_line|
          if /^(?<eki>[^(]+)/ =~ eki_line
            words = [eki, eki[0, eki.length - 1]]
            words.each do |word|
              next if word.length < 2

              word_length = word.length
              score = [-36000.0, -400 * (word_length ** 1.5)].max.to_i
              csv << [word, nil, nil, score, '名詞', '固有名詞', '地域', '一般', '*', '*', word, '*', '*', 'station']
            end
          end
        end
      end

      mecab_dict_index =  "#{Settings.mecab.mecab_dict_index_path} -d #{Settings.mecab.neologd} -u #{Settings[:mecab][:userdic]} -f utf-8 -t utf-8 #{dir}custom.csv"
      Rails.logger.info mecab_dict_index
      %x(#{mecab_dict_index})
      S3Wrapper.upload('custom.dic', Settings[:mecab][:userdic])

    rescue => e
      Rails.logger.error e
    ensure
      File.delete(downloaded_path) if File.exist?(downloaded_path)
      File.delete(expanded_path) if File.exist?(expanded_path)
    end
  end

  task fetch_mecab_userdic: :environment do
    begin
      dir = "#{Rails.root}/tmp/dictionary/"
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

      S3Wrapper.download('custom.dic', Settings[:mecab][:userdic])
    rescue => e
      Rails.logger.error e
    end
  end
end
