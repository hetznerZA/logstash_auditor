require "net/http"
require "soar_auditor_api"

module LogstashAuditor
  class LogstashAuditor < SoarAuditorApi::SoarAuditorAPI

    def configuration_is_valid(configuration = {})
      required_parameters = ["host_url", "use_ssl", "username", "password"]
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return true

      #TODO Remove the use ssl paramter by better looking at the url.
    end

    def audit(data)
      data = { "message" => data }
      send_event( data )
    end

    private

    def create_http_transport
      uri = URI.parse(@configuration["host_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = @configuration["timeout"]
      http.open_timeout = @configuration["timeout"]

      if @configuration["use_ssl"]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      return http, uri
    end

    def send_event(data)
      http, uri = create_http_transport


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
  end
end
