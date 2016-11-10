require "net/http"
require "soar_auditor_api"

module LogstashAuditor
  class LogstashAuditor < SoarAuditorApi::AuditorAPI
    def initialize(configuration = nil)
      @transport = nil
      super(configuration)
    end

    #inversion of control method required by the AuditorAPI
    def configuration_is_valid?(configuration)
      basic_auth_configuration_valid?(configuration) or
      certificate_auth_configuration_valid?(configuration)
    end

    #inversion of control method required by the AuditorAPI
    def audit(audit_data)
      transport.audit(audit_data)
    end

    private

    def basic_auth_configuration_valid?(configuration)
      required_parameters = ['host_url', 'username', 'password']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    def certificate_auth_configuration_valid?(configuration)
      required_parameters = ['host_url', 'certificate', 'private_key']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true
    end

    def transport
      create_transport if @transport.nil?
      raise StandardError, 'No transport available' if @transport.nil?
      @transport
    end

    def create_transport
      @transport = HttpTransport.new(@configuration) if @transport.nil? and url_scheme.include?('http')
      @transport = TcpTransport.new(@configuration)  if @transport.nil? and url_scheme.include?('tcp')
      @transport
    end

    def url_scheme
      scheme = URI.parse(@configuration['host_url']).scheme
      raise StandardError, "Unable to parse url scheme from #{@configuration['host_url']}" if scheme.nil?
      scheme
    end
  end
end
