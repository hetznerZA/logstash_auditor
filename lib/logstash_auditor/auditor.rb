require 'json'
require "net/http"
require "uri"

module LogstashAuditor
  class LogstashAuditor
    attr_reader :has_been_configured
    attr_reader :configuration

    def initialize
      @has_been_configured = false
    end

    def configure(configuration = nil)
      raise ArgumentError, "No configuration provided" if configuration == nil
      raise ArgumentError, "Invalid configuration provided" unless configuration_is_good(configuration)

      @configuration = configuration
      @has_been_configured = true
    end

    def event(flow_id, message)
      raise ArgumentError, "No flow id provided" if flow_id == nil
      data = { "flow_id" => flow_id, "message" => message }
      send_event( data )
    end

    private

    def send_event(data)
      uri = URI.parse(@configuration["host_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = @configuration["timeout"]
      http.open_timeout = @configuration["timeout"]

      if @configuration["use_ssl"]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request.basic_auth(@configuration["username"], @configuration["password"])
      request.body = data.to_json

      response = http.request(request)

      case response.code
      when "200"
        return :success
      when "401"
        puts "Authorization failure contacting to logstash"
      else
        puts "Failure " + response.code + " communicating with logstash"
      end
      return :failure
    end

    def configuration_is_good(configuration)
      unless configuration.include?("host_url")
        puts "Parameter host_url not provided in configuration"
        return false
      end
      unless configuration.include?("use_ssl")
        puts "Parameter use_ssl not provided in configuration"
        return false
      end
      unless configuration.include?("username")
        puts "Parameter username not provided in configuration"
        return false
      end
      unless configuration.include?("password")
        puts "Parameter password not provided in configuration"
        return false
      end
      unless configuration.include?("timeout")
        puts "Parameter timeout not provided in configuration"
        return false
      end
      return true
    end
  end
end
