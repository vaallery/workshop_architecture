# frozen_string_literal: true

class LikesProducer < KafkaProducer # < RabbitProducer - если нужно постепенно переводить очереди с кролика на кафку
  topic_name :likes
end
