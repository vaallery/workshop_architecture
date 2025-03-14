# frozen_string_literal: true

class LikesConsumer < KafkaConsumer
  def consume
    messages.each do |message|
      puts message.raw_payload # Обработка сообщения
    end
  end
end
