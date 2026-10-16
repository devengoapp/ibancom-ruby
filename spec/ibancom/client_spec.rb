# frozen_string_literal: true

RSpec.describe Ibancom::Client do
  let(:client) { described_class.new({ apikey: "test" }.merge(options)) }
  let(:options) { {} }
  let(:handlers) { client.connection.builder.handlers }
  let(:password_filter) { [/("password":)"(\w+)"/, '\1[FILTERED]'] }

  describe "logger middleware" do
    it "registers Faraday::Response::Logger with the original configuration" do
      handler = handlers.last
      recorder = filter_recorder

      expect(handlers.map(&:klass)).to eq([
        Faraday::Request::UrlEncoded,
        Faraday::Response::RaiseError,
        Faraday::Response::Json,
        Faraday::Response::Logger,
      ])
      expect(handler.instance_variable_get(:@args)).to eq([nil, { headers: true, bodies: true }])

      handler.instance_variable_get(:@block).call(recorder)
      expect(recorder.calls).to eq([password_filter])
    end

    context "when a custom middleware is provided" do
      let(:logger_middleware) do
        Class.new(Faraday::Middleware) do
          class << self
            attr_accessor :logger, :recorded_options, :filter_pattern, :filter_replacement
          end

          def initialize(app, logger = nil, middleware_options = {})
            self.class.logger = logger
            self.class.recorded_options = middleware_options
            super(app)
            yield self if block_given?
          end

          def filter(pattern, replacement)
            self.class.filter_pattern = pattern
            self.class.filter_replacement = replacement
          end
        end
      end
      let(:options) do
        {
          logger_middleware: logger_middleware,
          logger_options: { log_level: :debug },
        }
      end

      it "registers that middleware with the extra options and the password filter" do
        handlers.last.build(->(env) { env })

        expect(handlers.map(&:klass)).to eq([
          Faraday::Request::UrlEncoded,
          Faraday::Response::RaiseError,
          Faraday::Response::Json,
          logger_middleware,
        ])
        expect(logger_middleware.logger).to be_nil
        expect(logger_middleware.recorded_options).to eq({ headers: true, bodies: true, log_level: :debug })
        expect([logger_middleware.filter_pattern, logger_middleware.filter_replacement]).to eq(password_filter)
      end
    end

    context "when logging is disabled" do
      let(:logger_middleware) { Class.new(Faraday::Middleware) }
      let(:options) { { logger_enabled: false, logger_middleware: logger_middleware } }

      it "does not register the middleware" do
        expect(handlers.map(&:klass)).to eq([
          Faraday::Request::UrlEncoded,
          Faraday::Response::RaiseError,
          Faraday::Response::Json,
        ])
      end
    end
  end

  def filter_recorder
    Class.new do
      attr_reader :calls

      def initialize
        @calls = []
      end

      def filter(pattern, replacement)
        @calls << [pattern, replacement]
      end
    end.new
  end
end
