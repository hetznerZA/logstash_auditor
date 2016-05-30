require 'logstash_auditor'
require 'soar_auditing_format'
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
    @iut.set_audit_level(:debug)

    my_optional_field = SoarAuditingFormatter::Formatter.optional_field_format("mykey", "myfield")
    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now,"#{my_optional_field} test message with optional field"))
  end
end

main = Main.new
main.test_sanity
