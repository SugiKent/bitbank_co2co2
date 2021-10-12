# frozen_string_literal: true

require 'ruby_bitbankcc'
require 'dotenv/load'

KEY = ENV['BITBANK_AUTO_KEY']
SECRET = ENV['BITBANK_AUTO_SECRET']
IS_PRODUCTION = ENV['IS_PRODUCTION'] == 'true' || false
YEN_AMOUNT = ENV['YEN_AMOUNT'].to_i

# 念の為5の倍数の日以外は早期 return
# cron でも制御するが
return unless (Time.now.day % 5).zero?

puts "[#{Time.now}]"

client = Bitbankcc.new(KEY, SECRET)
res = client.read_ticker('btc_jpy')
price = JSON.parse(res.body, symbolize_names: true)
price_data = price[:data]
puts "price_data: #{price_data}"

buy_price = price_data[:buy].to_f
buy_btc_price = buy_price * 0.9999 # 300万なら 2,999,700
buy_btc_amount = YEN_AMOUNT / buy_btc_price # 300万で1000円分なら 0.000333367btc
buy_btc_amount.to_f.floor(8)

transaction = {
  side: 'buy',
  pair: 'btc_jpy',
  amount: buy_btc_amount,
  price: buy_btc_price,
  type: 'limit', # 指値
  is_production: IS_PRODUCTION
}

puts "transaction: #{transaction}"

order_res = client.create_order(
  transaction['pair'],
  transaction['amount'],
  transaction['price'],
  transaction['side'],
  transaction['type']
)

puts order_res
