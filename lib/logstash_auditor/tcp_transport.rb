require 'socket'
require 'json'

module LogstashAuditor
  class TcpTransport
    def initialize(configuration)
      @configuration = configuration
    end

    def audit(audit_data)
      sock = TCPSocket.new(remote_host, remote_port)
      sock.sync = true
      sock.write JSON.dump(audit_data)
      sock.close
    end

    private

    def remote_host
      host = URI.parse(@configuration['host_url']).host
      raise StandardError, "Unable to parse url host from #{@configuration['host_url']}" if host.nil?
      host
    end

    def remote_port
      port = URI.parse(@configuration['host_url']).port
      raise StandardError, "Unable to parse url port from #{@configuration['host_url']}" if port.nil?
      port
    end
  end
end
