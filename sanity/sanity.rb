require 'log4r'
require 'soar_logstash_auditor'
require 'byebug'

class Log4rAuditingProvider < SoarLogstashAuditor::AuditingProviderAPI
  def configure_auditor(configuration = nil)
    @auditor.outputters = configuration['outputter']
  end
end

class Main
  include Log4r
  
  def test_sanity
    auditor = Logger.new 'sanity'
    auditor_configuration = { 'outputter' => Outputter.stdout }
    @iut = Log4rAuditingProvider.new(auditor, auditor_configuration)

    some_debug_object = 123
    @iut.info("This is info")
    @iut.debug(some_debug_object)
    dropped = 95
    @iut.warn("Statistics show that dropped packets have increased to #{dropped}%")
    @iut.error("Could not resend some dropped packets. They have been lost. All is still OK, I could compensate")
    @iut.fatal("Unable to perform action, too many dropped packets. Functional degradation.")
    @iut << 'Rack::CommonLogger requires this'
  end
end

main = Main.new
main.test_sanity
