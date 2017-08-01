require 'logstash_auditor'
require 'soar_auditing_format'
require 'time'
require 'securerandom'

class Main

  #2016
  def test_sanity_using_previous_cert_on_staging
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration = { "host_url"    => "https://logstash-staging1.jnb1.host-h.net:8080",
      "certificate"  => File.read("/home/barney/Documents/20160909_logstash_production_client_certificate/soar.logstash.production.client.cert.pem"),
      "private_key"  => File.read("/home/barney/Documents/20160909_logstash_production_client_certificate/soar.logstash.production.client.private.nopass.pem"),
                                "timeout"     => 3}
    @iut.configure(@logstash_configuration)
    @iut.set_audit_level(:debug)

    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"test message without analytics field"))
    puts "Passed 2016 cert with staging"
  rescue
    puts "Failed 2016 cert with staging"
  end

  #2017
  def test_sanity_on_staging
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration = { "host_url"    => "https://logstash-staging1.jnb1.host-h.net:8080",
                                "certificate"  => File.read("/home/barney/Documents/20170621_logstash_production_and_staging_client_certificates/soar.logstash.staging.client.cert.pem"),
                                "private_key"  => File.read("/home/barney/Documents/20170621_logstash_production_and_staging_client_certificates/soar.logstash.staging.client.private.nopass.pem"),
                                "timeout"     => 3}
    @iut.configure(@logstash_configuration)
    @iut.set_audit_level(:debug)

    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"test message without analytics field"))
    puts "Passed 2017 cert with staging"
  rescue
    puts "Failed 2017 cert with staging"
  end

  #2016
  def test_sanity_using_previous_cert_on_production
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration = { "host_url"    => "https://logstash.jnb1.host-h.net:8080",
                                "certificate"  => File.read("/home/barney/Documents/20160909_logstash_production_client_certificate/soar.logstash.production.client.cert.pem"),
                                "private_key"  => File.read("/home/barney/Documents/20160909_logstash_production_client_certificate/soar.logstash.production.client.private.nopass.pem"),
                                "timeout"     => 3}
    @iut.configure(@logstash_configuration)
    @iut.set_audit_level(:debug)

    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"test message without analytics field"))
    puts "Passed 2016 cert with production"
  rescue
    puts "Failed 2016 cert with production"
  end

  #2017
  def test_sanity_on_production

    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration = { "host_url"    => "https://logstash.jnb1.host-h.net:8080",
                                "certificate"  => File.read("/home/barney/Documents/20170621_logstash_production_and_staging_client_certificates/soar.logstash.production.client.cert.pem"),
                                "private_key"  => File.read("/home/barney/Documents/20170621_logstash_production_and_staging_client_certificates/soar.logstash.production.client.private.nopass.pem"),
                                "timeout"     => 3}
    @iut.configure(@logstash_configuration)
    @iut.set_audit_level(:debug)

    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"test message without analytics field"))
    puts "Passed 2017 cert with production"
  rescue
    puts "Failed 2017 cert with production"
  end
end

main = Main.new
main.test_sanity_using_previous_cert_on_production
main.test_sanity_on_production
main.test_sanity_using_previous_cert_on_staging
main.test_sanity_on_staging
