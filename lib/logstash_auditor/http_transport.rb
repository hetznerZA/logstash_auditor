require "net/http"

module LogstashAuditor
  class HttpTransport
    def initialize(configuration)
      @configuration = configuration
    end

    def audit(audit_data)
      request = create_request(audit_data)
      @http = create_http_transport if not @http
      send_request_to_server(@http, request)
    end

    private

    def create_http_transport
      uri = URI.parse(@configuration['host_url'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.is_a?(URI::HTTPS)
      http.read_timeout = @configuration['timeout']
      http.open_timeout = @configuration['timeout']
      add_certificate_authentication(http) if certificate_auth_configuration_valid?(@configuration)
      return http
    end

    def certificate_auth_configuration_valid?(configuration)
      required_parameters = ['host_url', 'certificate', 'private_key']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    def add_certificate_authentication(http)
      http.cert = OpenSSL::X509::Certificate.new(@configuration['certificate'])
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
