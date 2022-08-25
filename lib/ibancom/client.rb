# frozen_string_literal: true

require "faraday"
require "securerandom"

# require "faraday_middleware"
require_relative "api/services"
require_relative "resources/base"

module Ibancom
  class Client
    include Ibancom::API::Services

    BASE_URL = "https://api.iban.com/clients/api"

    attr_reader :base_url, :user_agent, :proxy, :apikey, :logger_enabled

    def initialize(options = {})
      @base_url = options[:base_url] || BASE_URL
      @user_agent = options[:user_agent] || default_user_agent
      @proxy = options[:proxy]
      @apikey = options[:apikey] || ENV["IBANCOM_APIKEY"]
      @logger_enabled = options[:logger_enabled].nil? ? true : options[:logger_enabled]
      @services = {}
    end

    def connection
      @connection ||= Faraday.new do |builder|
        builder.request :url_encoded
        builder.use Faraday::Response::RaiseError
        builder.response :json,
                         content_type: /\bjson$/,
                         preserve_raw: true,
                         parser_options: { symbolize_names: true }
        builder.proxy = @proxy if proxy
        if @logger_enabled
          builder.response :logger, nil, { headers: true, bodies: true } do |logger|
            logger.filter(/("password":)"(\w+)"/, '\1[FILTERED]')
          end
        end
        builder.adapter :net_http
      end
    end

    def resources
      @resources ||= {}
    end

    def default_user_agent
      "Ibancom/#{Ibancom::VERSION} Ruby Client (Faraday/#{Faraday::VERSION})"
    end

    def get(path, options = {})
      execute :get, path, nil, options
    end

    def post(path, data = nil, options = {})
      execute :post, path, data, options
    end

    def patch(path, data = nil, options = {})
      execute :patch, path, data, options
    end

    def execute(method, path, data = nil, options = {})
      request(method, path, data, options)
    end

    def request(method, path, data = nil, options = {})
      request_options = request_options(method, path, data, options)
      uri = "#{base_url}#{path}"

      begin
        connection.run_request(method, uri, request_options[:body], request_options[:headers])
      rescue StandardError => e
        handle_request_error(e)
      end
    end

    def request_options(_method, _path, data, _options)
      default_options.tap do |defaults|
        defaults[:body] = defaults[:body].merge(data)
      end
    end

    def handle_request_error(error)
      case error
      when Faraday::ClientError
        if error.response
          handle_error_response(error)
        else
          handle_network_error(error)
        end
      else
        raise error
      end
    end

    def handle_error_response(error)
      puts "ERROR #{error.response}"
      raise error
    end

    def handle_network_error(error)
      raise error
    end

    private def default_options
      {
        url: base_url,
        headers: {
          "User-Agent": default_user_agent,
        },
        body: {
          format: "json",
          api_key: apikey,
        },
      }
    end
  end
end
