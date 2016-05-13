module SoarLogstashAuditor
  class AuditingProviderAPI
    attr_accessor :auditor

    def initialize(auditor, auditor_configuration = nil)
      raise ArgumentError.new("No auditor provided") if auditor.nil?
      @auditor = auditor
      configure_auditor(auditor_configuration)
    end

    def debug(data)
      @auditor.debug(data)
    end

    def <<(data)
      @auditor.info(data)
    end

    def info(data)
      @auditor.info(data)
    end

    def error(data)
      @auditor.error(data)
    end

    def warn(data)
      @auditor.warn(data)
    end

    def fatal(data)
      @auditor.fatal(data)
    end
  end
end
