# Getting Started

Start up Redis
$> redis-server /usr/local/etc/redis.conf

Start up Sidekiq
$> bundle exec sidekiq -r ./redis-stress.rb

Start up Sinatra
$> rackup -p 4567

Send some data to the app
$> curl http://localhost:4567/msg -d "msg=Hello wurld"

Look at the app
$> http://localhost:4567

Check out the Sidekiq dashboard
%> http://localhost:4567/sidekiq
