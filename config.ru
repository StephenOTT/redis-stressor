require './redis-stressor'
require 'sidekiq/web'

run RedisStressor
run Rack::URLMap.new('/' => RedisStressor, '/sidekiq' => Sidekiq::Web)
