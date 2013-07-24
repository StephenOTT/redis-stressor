require 'bundler/setup'
require 'haml'
require 'redis'
require 'sidekiq'
require 'sidekiq/web'
require 'sinatra'

$redis = Redis.connect

# Pushes a message into the database
class MessageWorker
  include Sidekiq::Worker

  def perform(msg="Yes, this is message")
    $redis.lpush('test-messages', msg)
  end
end

# Pushes the current date-time into the database
class CounterWorker
  include Sidekiq::Worker

  def perform
    $redis.lpush('test-counter', DateTime.now.to_s)
  end
end

class StrToDate
  def self.parse(obj)
    return '' if obj.nil?
    obj = obj[0] if obj.kind_of? Array
    DateTime.strptime(obj)
  end
end

# ------------------------------ App ------------------------------

class RedisStressor < Sinatra::Base
  COUNTER_LIST = 'test-counter'
  MESSAGE_LIST = 'test-messages'

  get '/' do
    stats = Sidekiq::Stats.new
    @last_count = StrToDate.parse($redis.lrange(COUNTER_LIST, -1, -1))
    @count_len  = $redis.llen(COUNTER_LIST)

    @messages = $redis.lrange(MESSAGE_LIST, 0, -1)
    @message_len = $redis.llen(MESSAGE_LIST)

    haml :index
  end

  post '/msg' do
    log params
    MessageWorker.perform_async params[:msg]
    ok
   end

  post '/count' do
    log params
    params[:count].to_i.times { CounterWorker.perform_async }
    ok
  end

  post '/request' do

  end

  get '/reset' do
    log 'resetting'
    $redis.del(COUNTER_LIST)
    $redis.del(MESSAGE_LIST)
    ok
  end

  private

    def log(msg)
      puts "-- Log: #{msg.inspect}"
    end

    def ok
      status 200
    end
end


