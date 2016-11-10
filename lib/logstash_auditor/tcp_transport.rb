require 'socket'
require 'json'
require 'openssl'

module LogstashAuditor
  class TcpTransport
    def initialize(configuration)
      @configuration = configuration
    end

    def audit(audit_data)
      @ssl_socket = create_ssl_socket unless @ssl_socket
      @ssl_socket.puts JSON.dump(audit_data)
    end

    private

    def create_ssl_socket
      ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context)
      ssl_socket.sync_close = true
      ssl_socket.connect
      ssl_socket
    end

    def tcp_socket
      socket = TCPSocket.new(remote_host, remote_port)
      socket.sync = true
      socket
    end

    def ssl_context
      ssl_context = OpenSSL::SSL::SSLContext.new()
      ssl_context.cert = OpenSSL::X509::Certificate.new(@configuration['certificate'])
      ssl_context.key = OpenSSL::PKey::RSA.new(@configuration['private_key'])
      ssl_context.ssl_version = :SSLv23
      ssl_context
    end

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
