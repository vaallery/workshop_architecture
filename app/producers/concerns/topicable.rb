# frozen_string_literal: true

module Topicable
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :topic

    def topic_name(q)
      @topic = q.to_s
    end
  end
end
