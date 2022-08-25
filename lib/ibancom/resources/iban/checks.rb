# frozen_string_literal: true

module Ibancom
  module Resources
    module IBAN
      class Checks < Collection
        def initialize(response, attributes_collection)
          parsed = attributes_collection.map do |check_attributes|
            {
              type: check_attributes[0],
              code: check_attributes[1][:code],
              message: check_attributes[1][:message],
            }
          end
          super(response, Check, parsed)
        end
      end
    end
  end
end
