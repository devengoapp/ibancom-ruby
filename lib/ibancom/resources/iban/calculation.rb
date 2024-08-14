# frozen_string_literal: true

module Ibancom
  module Resources
    module IBAN
      class Calculation < Base
        attr_accessor :error,
                      :account,
                      :address,
                      :bank,
                      :bic,
                      :branch,
                      :city,
                      :country,
                      :email,
                      :fax,
                      :iban,
                      :phone,
                      :sort_code,
                      :state,
                      :website,
                      :zip
      end
    end
  end
end
