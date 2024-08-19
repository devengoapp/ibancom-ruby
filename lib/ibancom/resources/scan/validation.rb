# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Validation < Base
        attr_reader :bank,
                    :account,
                    :checks,
                    :schemes

        def initialize(response, attributes = {})
          super(response, attributes)
          @bank = Bank.new(response, attributes[:bank_data])
          @account = Account.new(response, attributes[:account_data])
          @checks = Checks.new(response, attributes[:validations])
          @schemes = Schemes.new(response, attributes[:payment_schemes])
        end

        def valid?
          checks.all?(&:passed?)
        end

        def failed_checks
          checks.select(&:failed?)
        end

        def supported_schemes
          schemes.select(&:supported?)
        end

        def supported_scheme?(code)
          scheme = supported_schemes.find { |supported| supported.code == code }

          return false if scheme.nil?

          scheme.supported?
        end
      end
    end
  end
end
