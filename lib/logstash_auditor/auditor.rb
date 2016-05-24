require "net/http"
require "soar_auditor_api"

module LogstashAuditor
  class LogstashAuditor < SoarAuditorApi::AuditorAPI

    #inversion of control method required by the AuditorAPI
    def configuration_is_valid(configuration)
      required_parameters = ["host_url", "username", "password"]
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    #inversion of control method required by the AuditorAPI
    def audit(audit_data)
      request = create_request(audit_data)
      http    = create_http_transport
      send_request_to_server(http, request)
    end

    private

    def create_http_transport
      uri = URI.parse(@configuration["host_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.is_a?(URI::HTTPS)
      http.read_timeout = @configuration["timeout"]
      http.open_timeout = @configuration["timeout"]
      return http
    end

    def create_request(audit_data)
      request = Net::HTTP::Post.new("/", initheader = {'Content-Type' => 'application/json'})
      request.basic_auth(@configuration["username"], @configuration["password"])
      request.body = audit_data
      return request
    end

    def send_request_to_server(http, request)
      response = http.request(request) rescue nil
      raise StandardError, 'Failed to create connection' if response.nil?
      raise StandardError, "Server rejected post with error code #{response.code}" unless response.code == "200"
    end
  end
end
