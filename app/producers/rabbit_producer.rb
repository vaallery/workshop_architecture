# frozen_string_literal: true

class RabbitProducer
  include Topicable
  class << self
    def send(payload)
      payload = payload.to_json unless payload.is_a?(String)
      queue.publish(payload)
    end

    def queue
      @queue ||= channel.queue(topic, durable: true, auto_delete: false)
    end

    def channel
      @channel ||= connection.create_channel
    end

    attr_writer :connection

    def connection
      @connection ||= Bunny.new(
        host: ENV['RABBITMQ_HOST'] || 'rabbitmq',
        port: ENV['RABBITMQ_PORT'] || 5672,
        user: ENV.fetch('RABBITMQ_USER', nil),
        password: ENV.fetch('RABBITMQ_PASSWORD', nil)
      ).tap(&:start)
    end
  end
end
