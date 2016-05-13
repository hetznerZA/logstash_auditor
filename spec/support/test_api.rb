require 'soar_logstash_auditor/auditing_provider_api'

module SoarLogstashAuditor
  class TestAPI < SoarLogstashAuditor::AuditingProviderAPI
    def configure_auditor(configuration = nil)
      @auditor.configure(configuration)
    end
  end
end