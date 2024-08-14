# frozen_string_literal: true

module Ibancom
  module API
    class CalculationService < Service
      def calculate(options = {})
        options[:format] = "json"
        response = client.post("/calc-api.php", options)
        Resources::IBAN::Calculation.new(response, response.body)
      end
    end
  end
end
