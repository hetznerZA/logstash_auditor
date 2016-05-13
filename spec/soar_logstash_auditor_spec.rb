require 'spec_helper'

describe SoarLogstashAuditor do
  before :all do
    @iut = SoarLogstashAuditor::LogstashAuditor.new
    @invalid_configuration = { "bla" => "bla"}
    @valid_configuration = { "host_url" => "something",
                             "username" => "something",
                             "password" => "something",
                             "timeout"  => "something"}
  end

  it 'has a version number' do
    expect(SoarLogstashAuditor::VERSION).not_to be nil
  end

  context "when initializing" do
    it 'should accept a valid auditor configuration' do
      @iut.configure(@valid_configuration)
      expect(@iut.has_been_configured).to eq(true)
    end

    it 'should raise ArgumentError if no configuration is specified' do
      expect {
        @iut.configure(nil)
      }.to raise_error(ArgumentError, "No configuration provided")
    end

    it 'should raise ArgumentError if invalid configuration is specified' do
      expect {
        @iut.configure(@invalid_configuration)
      }.to raise_error(ArgumentError, "Invalid configuration provided")
    end
  end

  context "when asked to debug" do
    it "should ask the auditor to debug, giving it data received" do
      @iut.debug("test-debug")
      expect(@iut.log.include?("debug: test-debug")).to eq(true)
    end

    it "should ask the auditor to debug without data, if no data was provided" do
      @iut.debug("")
      expect(@iut.log.include?("debug: ")).to eq(true)
    end
  end

  context "when asked to info" do
    it "should ask the auditor to info, giving it data received" do
      @iut.info("test-info")
      expect(@iut.log.include?("info: test-info")).to eq(true)
    end

    it "should ask the auditor to info without data, if no data was provided" do
      @iut.info("")
      expect(@iut.log.include?("info: ")).to eq(true)
    end
  end

  context "when asked to error" do
    it "should ask the auditor to error, giving it data received" do
      @iut.error("test-error")
      expect(@iut.log.include?("error: test-error")).to eq(true)
    end

    it "should ask the auditor to error without data, if no data was provided" do
      @iut.error("")
      expect(@iut.log.include?("error: ")).to eq(true)
    end
  end

  context "when asked to warn" do
    it "should ask the auditor to warn, giving it data received" do
      @iut.warn("test-warn")
      expect(@iut.log.include?("warn: test-warn")).to eq(true)
    end

    it "should ask the auditor to warn without data, if no data was provided" do
      @iut.warn("")
      expect(@iut.log.include?("warn: ")).to eq(true)
    end
  end

  context "when asked to fatal" do
    it "should ask the auditor to fatal, giving it data received" do
      @iut.fatal("test-fatal")
      expect(@iut.log.include?("fatal: test-fatal")).to eq(true)
    end

    it "should ask the auditor to fatal without data, if no data was provided" do
      @iut.fatal("")
      expect(@iut.log.include?("fatal: ")).to eq(true)
    end
  end
end
