# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Bank < Base
        attr_accessor :bic,
                      :branch,
                      :bank,
                      :address,
                      :city,
                      :zip,
                      :phone,
                      :country
      end
    end
  end
end
