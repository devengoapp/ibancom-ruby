# frozen_string_literal: true

module Ibancom
  module Resources
    class Base
      attr_reader :response

      def initialize(response, attributes = {})
        @response = response
        attributes.each do |key, value|
          m = "#{key}=".to_sym
          send(m, value) if respond_to?(m)
        end
      end

      def self.map(original_attribute, mapped_attributes)
        class_eval { attr_writer original_attribute.to_sym }
        mapped_attributes = [mapped_attributes].flatten
        mapped_attributes.each do |mapped_attribute|
          define_method(mapped_attribute) { instance_variable_get("@#{original_attribute}") }
        end
      end
    end
  end
end

require_relative "collection"
require_relative "iban/validation"
require_relative "iban/bank"
require_relative "iban/checks"
require_relative "iban/check"
require_relative "iban/schemes"
require_relative "iban/scheme"
require_relative "scan/validation"
require_relative "scan/bank"
require_relative "scan/account"
require_relative "scan/checks"
require_relative "scan/check"
require_relative "scan/schemes"
require_relative "scan/scheme"
