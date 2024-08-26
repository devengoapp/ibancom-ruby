# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Schemes < Collection
        def initialize(response, attributes_collection)
          parsed = attributes_collection.map do |attributes|
            {
              code: attributes[0],
              supported: attributes[1],
            }
          end
          super(response, Scheme, parsed)
        end
      end
    end
  end
end
