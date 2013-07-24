require './redis-stress'
require 'sidekiq/web'

run RedisStress
run Rack::URLMap.new('/' => RedisStress, '/sidekiq' => Sidekiq::Web)
