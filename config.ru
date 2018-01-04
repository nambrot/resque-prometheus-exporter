require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'prometheus/client'
require 'resque'

uri = URI.parse(ENV['REDIS_URL'] || 'redis://localhost:6379')
Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password, thread_safe: true)

class Metrics
  attr_reader :app
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @metrics_prefix = options[:metrics_prefix] || ENV['METRICS_PREFIX'] || ''
    @labels = options[:labels] || symbolize_keys(JSON.parse(ENV.fetch('METRICS_LABELS', '{}')))
    @queue_sizes = @registry.gauge(
      :"#{@metrics_prefix}working_queue_size",
      'The total number of jobs in a queue',
    )
    @failed_queue_length = @registry.gauge(
      :"#{@metrics_prefix}failed_queue_size",
      'The total number of failed jobs'
    )
  end

  def call(env)
    Resque.queues.each do |queue|
      @queue_sizes.set(@labels.merge({ queue: queue }), Resque.size(queue))
    end
    @failed_queue_length.set(@labels, Resque.info[:failed])
    @app.call(env)
  end

  private

  def symbolize_keys(hash)
    hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end
end

use Metrics
use Prometheus::Middleware::Exporter

srand

app = lambda do |_|
  [200, { 'Content-Type' => 'text/html' }, ['OK']]
end

run app
