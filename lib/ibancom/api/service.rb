# frozen_string_literal: true

module Ibancom
  module API
    class Service
      attr_reader :client

      def initialize(client)
        @client = client
      end
    end
  end
end
