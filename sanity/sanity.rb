require 'logstash_auditor'
require 'time'
require 'securerandom'

class Main
  def test_sanity
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration =
    { "host_url" => "http://localhost:8080",
      "username" => "auditorusername",
      "password" => "auditorpassword",
      "timeout"  => 3}
    @iut.configure(@logstash_configuration)

    @iut.warn("#{SecureRandom.hex(32)}:#{Time.now.utc.iso8601(3)}:test1234")
  end
end

main = Main.new
main.test_sanity
