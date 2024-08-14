# frozen_string_literal: true

require_relative "service"
require_relative "validation_service"
require_relative "calculation_service"

module Ibancom
  module API
    module Services
      def validations
        @services[:validation] ||= API::ValidationService.new(self)
      end

      def calculations
        @services[:calculation] ||= API::CalculationService.new(self)
      end
    end
  end
end
