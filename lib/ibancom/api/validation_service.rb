# frozen_string_literal: true

module Ibancom
  module API
    class ValidationService < Service
      def validate(iban)
        response = client.post("/v4/iban/", { iban: iban, sci: 1 })
        Resources::IBAN::Validation.new(response, response.body)
      end
    end
  end
end
