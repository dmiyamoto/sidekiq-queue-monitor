require 'json'
require 'redis-namespace'
require 'aws-sdk'
require 'sidekiq/api'

def lambda_handler(event:, context:)
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'], namespace: "sidekiq", network_timeout: 180 }
  end

  queue_types = JSON.parse(ENV['QUEUE_TYPES'])

  queue_types.each do |queue_type|
    clear_cache
    
    if size_metrics(queue_type) >= size_threshold || latency_metrics(queue_type) >= latency_threshold
      payload = {
                  error: false,
                  queue_type: queue_type,
                  size: size_metrics(queue_type),
                  latency: latency_metrics(queue_type),
                  size_threshold: size_threshold,
                  latency_threshold: latency_threshold
                }
  
      
      vpc_lambda_client.invoke({
        function_name: lambda_name_for_slack_notify, 
        payload: JSON.generate(payload)
      })
    end
  end
rescue => e
  payload = {
              error: true,
              msg: e.message
            }

  vpc_lambda_client.invoke({
    function_name: lambda_name_for_slack_notify, 
    payload: JSON.generate(payload)
  }) 
end

def size_threshold
  raise 'SIZE_THRESHOLD を設定してください。' if ENV['SIZE_THRESHOLD'].nil? || ENV['SIZE_THRESHOLD'].empty?
  ENV['SIZE_THRESHOLD'].to_i
end

def latency_threshold
  raise 'LATENCY_THRESHOLD を設定してください。' if ENV['LATENCY_THRESHOLD'].nil? || ENV['LATENCY_THRESHOLD'].empty?
  ENV['LATENCY_THRESHOLD'].to_i
end

def lambda_name_for_slack_notify
  raise 'LAMBDA_NAME_FOR_SLACK_NOTIFY を設定してください。' if ENV['LAMBDA_NAME_FOR_SLACK_NOTIFY'].nil? || ENV['LAMBDA_NAME_FOR_SLACK_NOTIFY'].empty?
  ENV['LAMBDA_NAME_FOR_SLACK_NOTIFY']
end

def vpc_lambda_client
  raise 'VPC_ENDPOINT を設定してください。' if ENV['VPC_ENDPOINT'].nil? || ENV['VPC_ENDPOINT'].empty?
  @client ||= Aws::Lambda::Client.new(endpoint: ENV["VPC_ENDPOINT"])
end

def size_metrics(queue_type)
  return @size_metrics if @size_metrics

  @size_metrics = Sidekiq::Queue.new(queue_type).size
end

def latency_metrics(queue_type)
  return @latency_metrics if @latency_metrics

  @latency_metrics = Sidekiq::Queue.new(queue_type).latency.floor
end

def clear_cache
  @size_metrics, @latency_metrics = nil
end
