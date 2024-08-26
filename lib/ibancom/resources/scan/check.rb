# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Check < Base
        PASSED_MESSAGES = {
          "001" => "Modulus Success: Check digit is valid",
          "002" => "Sort Code found in bank directory",
          "006" => "Sort Code does not contain illegal characters",
          "007" => "Account Number does not contain illegal characters",
          "008" => "Sort Code length is correct",
          "009" => "Account Number length is correct",
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
