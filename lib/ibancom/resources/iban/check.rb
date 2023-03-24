# frozen_string_literal: true

module Ibancom
  module Resources
    module IBAN
      class Check < Base
        PASSED_MESSAGES = {
          "001" => "IBAN Check digit is correct",
          "002" => "Account Number check digit is correct",
          "003" => "IBAN Length is correct",
          "004" => "Account Number check digit is not performed for this bank or branch",
          "005" => "IBAN structure is correct",
          "006" => "IBAN does not contain illegal characters",
          "007" => "Country supports IBAN standard",
        }.freeze

        attr_accessor :type,
                      :code,
                      :message

        def passed?
          PASSED_MESSAGES[code] == message
        end

        def failed?
          !passed?
        end
      end
    end
  end
end
