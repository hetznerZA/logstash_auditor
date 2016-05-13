require 'spec_helper'

describe SoarLogstashAuditor do
  before :all do
    @auditor = SoarLogstashAuditor::LogstashAuditor.new
    @auditor_configuration = {}
    @iut = SoarLogstashAuditor::TestAPI.new(@auditor, @auditor_configuration)
  end

  it 'has a version number' do
    expect(SoarLogstashAuditor::VERSION).not_to be nil
  end

  context "when initializing" do
    it 'should remember the auditing provider specified' do
      expect(@iut.auditor).to_not be_nil
      expect(@iut.auditor).to eq(@auditor)
    end

    it 'should not require an auditor configuration' do
      @iut = SoarLogstashAuditor::TestAPI.new(@auditor)
    end

    it 'should raise ArgumentError if no auditor is specified' do
      expect {
        @iut = SoarLogstashAuditor::TestAPI.new(nil)
      }.to raise_error(ArgumentError, "No auditor provided")
    end

    it 'should use inversion of control to itself in order to initialize the provider, using the configuration provided' do
      expect(@iut.auditor.has_been_configured).to eq(true)
      expect(@iut.auditor.configuration).to eq(@test_configuration)
    end

    it 'should use inversion of control to itself in order to initialize the provider, using no configuration if none is provided' do
      @iut = SoarLogstashAuditor::TestAPI.new(@auditor)
      expect(@iut.auditor.has_been_configured).to eq(true)
    end

    it 'should configure the auditor when its IOC has been called to do so' do
      expect(@iut.auditor.has_been_configured).to eq(true)
    end
  end

  context "when asked to debug" do
    it "should ask the auditor to debug, giving it data received" do
      @iut.debug("test-debug")
      expect(@iut.auditor.log.include?("debug: test-debug")).to eq(true)
    end

    it "should ask the auditor to debug without data, if no data was provided" do
      @iut.debug("")
      expect(@iut.auditor.log.include?("debug: ")).to eq(true)
    end
  end

  context "when asked to info" do
    it "should ask the auditor to info, giving it data received" do
      @iut.info("test-info")
      expect(@iut.auditor.log.include?("info: test-info")).to eq(true)
    end

    it "should ask the auditor to info without data, if no data was provided" do
      @iut.info("")
      expect(@iut.auditor.log.include?("info: ")).to eq(true)
    end
  end

  context "when asked to error" do
    it "should ask the auditor to error, giving it data received" do
      @iut.error("test-error")
      expect(@iut.auditor.log.include?("error: test-error")).to eq(true)
    end

    it "should ask the auditor to error without data, if no data was provided" do
      @iut.error("")
      expect(@iut.auditor.log.include?("error: ")).to eq(true)
    end
  end

  context "when asked to warn" do
    it "should ask the auditor to warn, giving it data received" do
      @iut.warn("test-warn")
      expect(@iut.auditor.log.include?("warn: test-warn")).to eq(true)
    end

    it "should ask the auditor to warn without data, if no data was provided" do
      @iut.warn("")
      expect(@iut.auditor.log.include?("warn: ")).to eq(true)
    end
  end

  context "when asked to fatal" do
    it "should ask the auditor to fatal, giving it data received" do
      @iut.fatal("test-fatal")
      expect(@iut.auditor.log.include?("fatal: test-fatal")).to eq(true)
    end

    it "should ask the auditor to fatal without data, if no data was provided" do
      @iut.fatal("")
      expect(@iut.auditor.log.include?("fatal: ")).to eq(true)
    end
  end

  context "when asked to append using <<" do
    it "should ask the auditor to append giving it data received" do
      @iut << "test-info"
      expect(@iut.auditor.log.include?("info: test-info")).to eq(true)
    end

    it "should ask the auditor to append without data, if no data was provided" do
      @iut << ""
      expect(@iut.auditor.log.include?("info: ")).to eq(true)
    end
  end
end
