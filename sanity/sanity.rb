$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'soar_logstash_auditor'
require 'byebug'

class Main
  def create_flow_id
    return Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(4000000)}")
  end

  def test_sanity
    @iut = LogstashAuditor::LogstashAuditor.new
    @valid_logstash_configuration = { "host_url" => "http://127.0.0.1:8080",
                             "username" => "something",
                             "password" => "something",
                             "timeout"  => 3}
    @iut.configure(@valid_logstash_configuration)
    @iut.event(create_flow_id, "This is info")
  end
end

main = Main.new
main.test_sanity
