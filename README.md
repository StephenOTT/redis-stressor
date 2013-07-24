# Getting Started

Start up Redis
$> redis-server /usr/local/etc/redis.conf

Start up Sidekiq
$> bundle exec sidekiq -r ./redis-stress.rb

Start up Sinatra
$> rackup -p 4567

Send a text message to the app
$> curl http://localhost:4567/msg -d "msg=Hello wurld"

Have the app perform a high volume of operations
$> curl http://localhost:4567/count -d "count=5000"

Reset all the values in the app
$> curl http://localhost:4567/reset

Look at the app
$> http://localhost:4567

Check out the Sidekiq dashboard
%> http://localhost:4567/sidekiq
