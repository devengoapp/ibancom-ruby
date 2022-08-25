# frozen_string_literal: true

module Ibancom
  module Resources
    module IBAN
      class Bank < Base
        attr_accessor :bic,
                      :branch,
                      :bank,
                      :address,
                      :city,
                      :state,
                      :zip,
                      :phone,
                      :fax,
                      :www,
                      :email,
                      :country,
                      :country_iso,
                      :account,
                      :bank_code,
                      :branch_code
      end
    end
  end
end
