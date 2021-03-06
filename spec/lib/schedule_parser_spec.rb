require 'rails_helper'

describe "schedule_parser" do
  let(:date) { Time.zone.now.to_date - 10 }

  it 'LINE1' do
    original = <<"EOS"
[定例フットサル] (屋外)

日程:#{date.strftime('%-m/%-d')}
時間:14:00-18:15
会費:500円
場所:中野区中部すこやか福祉センター
※最寄り駅:新中野徒歩7分
※東京都中野区中央三丁目19番1号

参加者はノートに記載してください。
友達を呼ぶ場合は、人数も記載してください。
でも、やっぱりドタ参・ドタキャン大歓迎です。

参加予定者は早め早めに参加表明お待ちしてます！
EOS

    schedule = ScheduleParser.parse(original)
    expect(schedule[:datetime]).to eq([Time.zone.parse(date.strftime('%m/%d 14:00')), Time.zone.parse(date.strftime('%m/%d 18:15'))])
    expect(schedule[:title]).to include('フットサル')
  end

  it 'LINE2' do
    original = <<"EOS"
【定例フットサル】(屋外)

日程:6/10(土)
時間:16:15-18:15
会費:500円
場所:中野区中部すこやか福祉センター
※最寄り駅:新中野徒歩7分
※東京都中野区中央三丁目19番1号

参加者はノートに記載してください。
友達を呼ぶ場合は、人数も記載してください。
でも、やっぱりドタ参・ドタキャン大歓迎です。

参加予定者は早め早めに参加表明お待ちしてます！

■参加予定0名
EOS

    schedule = ScheduleParser.parse(original)
    expect(schedule[:datetime]).to eq([Time.zone.parse('6/10 16:15'), Time.zone.parse(date.strftime('6/10 18:15'))])
    expect(schedule[:title]).to include('フットサル')
  end

  it 'LINE3' do
    original = "#{date.strftime('%-m/%-d')} 10:30〜 スタジオノア新宿のB3スタジオで予約取りましたー"

    schedule = ScheduleParser.parse(original)
    expect(schedule[:datetime]).to eq([Time.zone.parse(date.strftime('%m/%d 10:30'))])
  end

  it 'TWITTER1' do
    original = "今日の夜7時からは菜々美がshowroomやりますよ！！見てくださいね〜"

    schedule = ScheduleParser.parse(original)
    expect(schedule[:datetime]).to eq([Time.zone.parse(Time.now.strftime('%m/%d 19:00'))])
  end

  it 'TWITTER2' do
    original = <<"EOS"
明日の夜7時のミュージックステーションに
AKB48で出演させて頂くのですが
365日の紙飛行機は
私1人で歌わせて頂くことになりました。

急なお話に戸惑いもありましたが
1人でも、この曲が持つメッセージを
しっかり伝えられるよう
精一杯歌わせて頂きます。
EOS

    schedule = ScheduleParser.parse(original)
    expect(schedule[:datetime]).to eq([Time.zone.parse((Date.today + 1).strftime('%m/%d 19:00'))])
  end

  it 'TWITTER3' do
    original = <<"EOS"
明日の夜7時のミュージックステーションに
AKB48で出演させて頂くのですが
365日の紙飛行機は
私1人で歌わせて頂くことになりました。

急なお話に戸惑いもありましたが
1人でも、この曲が持つメッセージを
しっかり伝えられるよう
精一杯歌わせて頂きます。
EOS

    schedule = ScheduleParser.parse(original, time_zone: 'Tokyo', target_date: Date.parse('2000/1/1'))
    expect(schedule[:datetime]).to eq([Time.zone.parse('2000/1/2 10:00').in_time_zone('Tokyo')])
  end
end
