# frozen_string_literal: true

module Ibancom
  module Resources
    module SCAN
      class Scheme < Base
        attr_accessor :code,
                      :supported

        def supported?
          supported == "YES"
        end
      end
    end
  end
end
