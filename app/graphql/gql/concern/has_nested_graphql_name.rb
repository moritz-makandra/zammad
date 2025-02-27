# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

module Gql::Concern::HasNestedGraphqlName
  extend ActiveSupport::Concern

  included do
    def self.inherited(subclass)
      super
      return if !subclass.name

      subclass.graphql_name(subclass.name.sub(%r{Gql::[^:]+::}, '').gsub('::', '').sub(%r{Type\Z}, ''))
    end
  end
end
