# frozen_string_literal: true

RSpec.describe Ibancom::Client do
  let(:client) { described_class.new({ apikey: "test" }.merge(options)) }
  let(:options) { {} }
  let(:handlers) { client.connection.builder.handlers }
  let(:log_filters) { [[/("password":)"(\w+)"/, '\1[FILTERED]'], [/(api_key=)[^&\s]+/, '\1[FILTERED]']] }

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
      expect(recorder.calls).to eq(log_filters)
    end

    it "keeps the API key out of the log" do
      stub_request(:post, %r{/v4/iban/}).to_return(read_http_fixture("validations/validate/success.http"))
      validate = -> { described_class.new(apikey: "secret-api-key").validations.validate("ES7004878248947469245596") }

      expect(&validate).to output(a_string_including("api_key=[FILTERED]")).to_stdout
      expect(&validate).not_to output(/secret-api-key/).to_stdout
    end

    context "when a custom middleware is provided" do
      let(:logger_middleware) do
        Class.new(Faraday::Middleware) do
          class << self
            attr_accessor :logger, :recorded_options, :filters
          end

          def initialize(app, logger = nil, middleware_options = {})
            self.class.logger = logger
            self.class.recorded_options = middleware_options
            self.class.filters = []
            super(app)
            yield self if block_given?
          end

          def filter(pattern, replacement)
            self.class.filters << [pattern, replacement]
          end
        end
      end
      let(:options) do
        {
          logger_middleware: logger_middleware,
          logger_options: { log_level: :debug },
        }
      end

      it "registers that middleware with the extra options and the log filters" do
        handlers.last.build(->(env) { env })

        expect(handlers.map(&:klass)).to eq([
          Faraday::Request::UrlEncoded,
          Faraday::Response::RaiseError,
          Faraday::Response::Json,
          logger_middleware,
        ])
        expect(logger_middleware.logger).to be_nil
        expect(logger_middleware.recorded_options).to eq({ headers: true, bodies: true, log_level: :debug })
        expect(logger_middleware.filters).to eq(log_filters)
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

  describe "request errors" do
    let(:options) { { logger_enabled: false } }
    let(:validate) { client.validations.validate("ES7004878248947469245596") }

    context "when the API responds with a client error" do
      before do
        stub_request(:post, %r{/v4/iban/}).to_return(status: 401, body: '{"error":"invalid key"}')
      end

      it "raises the Faraday error with the response" do
        expect { validate }.to raise_error(Faraday::UnauthorizedError) do |error|
          expect(error.response[:status]).to eq(401)
        end
      end

      it "does not print the response" do
        expect { expect { validate }.to raise_error(Faraday::UnauthorizedError) }.not_to output.to_stdout
      end
    end

    context "when the API responds with a server error" do
      before { stub_request(:post, %r{/v4/iban/}).to_return(status: 503) }

      it "raises the Faraday error" do
        expect { validate }.to raise_error(Faraday::ServerError)
      end
    end

    context "when a client error has no response" do
      before { stub_request(:post, %r{/v4/iban/}).to_raise(Faraday::ClientError.new("no response")) }

      it "raises it unchanged" do
        expect { validate }.to raise_error(Faraday::ClientError, "no response")
      end
    end

    context "when the connection fails" do
      before { stub_request(:post, %r{/v4/iban/}).to_raise(Faraday::ConnectionFailed.new("refused")) }

      it "raises the Faraday error" do
        expect { validate }.to raise_error(Faraday::ConnectionFailed)
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

  describe "#inspect" do
    it "leaves the API key out, pp included" do
      client.connection

      expect([client.inspect, client.pretty_inspect]).to eq(["#<Ibancom::Client>", "#<Ibancom::Client>\n"])
    end
  end
end
