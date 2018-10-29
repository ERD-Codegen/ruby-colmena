# frozen_string_literal: true

require 'colmena/cell'
require 'colmena/transactions/materialize'
require 'real_world/article/materializer'

module RealWorld
  module Article
    class Cell
      include Colmena::Cell

      register_port :repository
      register_port :event_publisher

      TRANSACTION = Colmena::Transactions::Materialize[
        event_materializer: Materializer,
        event_stream: :article_events,
      ]

      require 'real_world/article/queries/read_article_by_slug'
      register_query Queries::ReadArticleBySlug

      require 'real_world/article/commands/create_article'
      register_command TRANSACTION[Commands::CreateArticle]
    end
  end
end
