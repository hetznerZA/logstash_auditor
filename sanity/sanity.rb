require 'logstash_auditor'

class Main
  def test_sanity
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration =
    { "host_url" => "http://localhost:8080",
      "username" => "auditorusername",
      "password" => "auditorpassword",
      "timeout"  => 3}
    @iut.configure(@logstash_configuration)

    require 'digest'
    flow_id = Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(4000000)}")

    @iut.warn("#{flow_id}:This is a test event")
  end
end

main = Main.new
main.test_sanity
