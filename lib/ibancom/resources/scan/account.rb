# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Account < Base
        attr_accessor :sortcode,
                      :account,
                      :iban
      end
    end
  end
end
