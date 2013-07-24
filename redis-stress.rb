require 'bundler/setup'
require 'haml'
require 'redis'
require 'sidekiq'
require 'sidekiq/web'
require 'sinatra'

$redis = Redis.connect

class MessageWorker
  include Sidekiq::Worker

  def perform(msg="Yes, this is message")
    $redis.lpush('test-messages', msg)
  end
end

class SmasherWorker
  include Sidekiq::Worker

  def perform
    $redis.lpush('test-counter', DateTime.now.to_s)
  end
end

# ------------------------------ App ------------------------------

class RedisStress < Sinatra::Base
  COUNTER_LIST = 'test-counter'
  MESSAGE_LIST = 'test-messages'

  get '/' do
    stats = Sidekiq::Stats.new
    @last_smash = $redis.lrange(COUNTER_LIST, -1, -1)
    @smash_len  = $redis.llen(COUNTER_LIST)

    @messages = $redis.lrange(MESSAGE_LIST, 0, -1)
    @message_len = $redis.llen(MESSAGE_LIST)

    haml :index
  end

  post '/msg' do
    log params
    MessageWorker.perform_async params[:msg]
    status 200
   end

  post '/smash' do
    log params
    params[:count].to_i.times do
      SmasherWorker.perform_async
    end
    log "Done smashing"
    status 200
  end

  private

    def log(msg)
      puts "-- Log: #{msg.inspect}"
    end
end


