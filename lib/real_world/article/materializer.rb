# frozen_string_literal: true

require 'colmena/materializer'
require 'real_world/article/domain'

module RealWorld
  module Article
    class Materializer < Colmena::Materializer
      def transaction
        port(:repository).transaction { yield }
      end

      def map(event)
        article = if event.fetch(:type) == :article_created
                    {}
                  else
                    port(:repository).read_by_id(event.fetch(:data).fetch(:id))
                  end

        Domain.apply(article, [event])
      end

      def call(event)
        return unless Domain.event?(event[:type])

        article = map(event)

        case event.fetch(:type)
        when :article_created then port(:repository).create(article)
        when :article_tag_added then port(:repository).update(article)
        when :article_favorited
          port(:repository).favorite(article, event.fetch(:data).fetch(:user_id))
        when :article_unfavorited
          port(:repository).unfavorite(article, event.fetch(:data).fetch(:user_id))
        end
        # TODO: Log unhandled event
      end
    end
  end
end
