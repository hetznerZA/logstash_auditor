require "net/http"
require "soar_auditor_api"

module LogstashAuditor
  class LogstashAuditor < SoarAuditorApi::AuditorAPI

    #inversion of control method required by the AuditorAPI
    def configuration_is_valid?(configuration)
      basic_auth_configuration_valid?(configuration) or
      certificate_auth_configuration_valid?(configuration)
    end

    #inversion of control method required by the AuditorAPI
    def audit(audit_data)
      request = create_request(audit_data)
      http = create_http_transport
      send_request_to_server(http, request)
    end

    private

    def basic_auth_configuration_valid?(configuration)
      required_parameters = ['host_url', 'username', 'password']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    def certificate_auth_configuration_valid?(configuration)
      required_parameters = ['host_url', 'public_key', 'private_key']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    def create_http_transport
      uri = URI.parse(@configuration['host_url'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.is_a?(URI::HTTPS)
      http.read_timeout = @configuration['timeout']
      http.open_timeout = @configuration['timeout']
      add_certificate_authentication(http) if certificate_auth_configuration_valid?(@configuration)
      return http
    end

    def add_certificate_authentication(http)
      http.cert = OpenSSL::X509::Certificate.new(@configuration['public_key'])
      http.key = OpenSSL::PKey::RSA.new(@configuration['private_key'])
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def create_request(audit_data)
      request = Net::HTTP::Post.new("/", initheader = {'Content-Type' => 'text/plain'})
      add_basic_auth(request) if @configuration['username'] and @configuration['password']
      request.body = audit_data
      return request
    end

    def add_basic_auth(request)
      request.basic_auth(@configuration['username'], @configuration['password'])
    end

    def send_request_to_server(http, request)
      response = http.request(request) rescue nil
      raise StandardError, 'Failed to create connection' if response.nil?
      raise StandardError, "Server rejected post with error code #{response.code}" unless response.code == "200"
    end
  end
end
