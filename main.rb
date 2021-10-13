# frozen_string_literal: true


# cron setting
# PATH=/sbin:/bin:/usr/sbin:/usr/bin:/home/kento/.rbenv/bin:/usr/bin/rbenv
# 0 0 */5 * * ~/Dev/bitbank_co2co2/exe.sh >> ~/Dev/bitbank_co2co2/cron.log 2>&1

require 'ruby_bitbankcc'
require 'dotenv/load'
require './line'

log = []

KEY = ENV['BITBANK_AUTO_KEY']
SECRET = ENV['BITBANK_AUTO_SECRET']
IS_PRODUCTION = ENV['IS_PRODUCTION'] == 'true' || false
YEN_AMOUNT = ENV['YEN_AMOUNT'].to_i

log << "[#{Time.now}]"

client = Bitbankcc.new(KEY, SECRET)
res = client.read_ticker('btc_jpy')
price = JSON.parse(res.body, symbolize_names: true)
price_data = price[:data]
log << "price_data: #{price_data}"

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
}

log << "transaction: #{transaction}"
log << "IS_PRODUCTION: #{IS_PRODUCTION}"

unless IS_PRODUCTION
  return
end

order_res = client.create_order(
  transaction['pair'],
  transaction['amount'],
  transaction['price'],
  transaction['side'],
  transaction['type']
)

log << order_res

puts log
Line.new.notify_msg(log)
