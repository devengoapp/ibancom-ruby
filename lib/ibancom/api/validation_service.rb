# frozen_string_literal: true

module Ibancom
  module API
    class ValidationService < Service
      def validate(iban)
        response = client.post("/v4/iban/", { iban: iban, sci: 1 })
        Resources::IBAN::Validation.new(response, response.body)
      end

      def validate_scan(sort_code, account_number)
        response = client.post("/v4/sort/", { sortcode: sort_code, account: account_number })
        Resources::SCAN::Validation.new(response, response.body)
      end
    end
  end
end
