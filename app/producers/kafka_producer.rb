# frozen_string_literal: true

class KafkaProducer
  include Topicable
  class << self
    def send(payload)
      payload = payload.to_json unless payload.is_a?(String)
      Karafka.producer.produce_async(topic: topic, payload: payload)
    end
  end
end
