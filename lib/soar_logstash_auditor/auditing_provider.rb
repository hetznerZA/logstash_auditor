module SoarLogstashAuditor
  class LogstashAuditor
    attr_reader :has_been_configured
    attr_reader :configuration
    attr_accessor :log

    def configure(configuration)
      @configuration = configuration
      @has_been_configured = true
    end

    def initialize
      @log = []
      @has_been_configured = false
    end

    def debug(data)
      @log << "debug: #{data}"
    end


    def error(data)
      @log << "error: #{data}"
    end


    def info(data)
      @log << "info: #{data}"
    end


    def fatal(data)
      @log << "fatal: #{data}"
    end


    def warn(data)
      @log << "warn: #{data}"
    end


    private

    def send_event(data)
      uri = URI.parse(@configuration["host_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = @configuration["timeout"]
      http.open_timeout = @configuration["timeout"]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE #TODO need implement and test the verification scheme of the logstash server cert
      request = Net::HTTP::Post.new(uri.request_uri)

      request.basic_auth(@configuration["username"], @configuration["password"])

      #TODO not yet sure what is the best way to send information to logstash.
      #sending as a map will replace spaces with + in logs
      #sending as combined json string will add http %% characters to logstash
      #sending as base64 encoded will require decoding in logstash filters
      request.set_form_data(data)
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


  end
end
