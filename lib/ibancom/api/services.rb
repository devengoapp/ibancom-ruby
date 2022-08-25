# frozen_string_literal: true

require_relative "service"
require_relative "validation_service"

module Ibancom
  module API
    module Services
      def validations
        @services[:validation] ||= API::ValidationService.new(self)
      end
    end
  end
end
