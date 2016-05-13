require 'soar_logstash_auditor/auditing_provider'
require 'soar_auditor'

module SoarLogstashAuditor
  class TestAPI < SoarAuditor::AuditingProviderAPI
    def configure_auditor(configuration = nil)
      @auditor.configure(configuration)
    end
  end
end
