module SoarLogstashAuditor
  class TestAuditor
    attr_reader :has_been_configured
    attr_reader :configuration
    attr_accessor :log

    def configure(configuration)
      @configuration = configuration
      @has_been_configured = true
    end

    def initialize
      @log = []
      @has_been_configured = false
    end

    def debug(data)
      @log << "debug: #{data}"
    end


    def error(data)
      @log << "error: #{data}"
    end


    def info(data)
      @log << "info: #{data}"
    end


    def fatal(data)
      @log << "fatal: #{data}"
    end


    def warn(data)
      @log << "warn: #{data}"
    end
  end
end