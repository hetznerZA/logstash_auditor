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

  context "when given debug" do
    it "should debug with data received" do
      @iut.debug("test-debug")
      expect(@iut.log.include?("debug: test-debug")).to eq(true)
    end

    it "should debug without data, if no data was provided" do
      @iut.debug("")
      expect(@iut.log.include?("debug: ")).to eq(true)
    end
  end

  context "when given info" do
    it "should info with data received" do
      @iut.info("test-info")
      expect(@iut.log.include?("info: test-info")).to eq(true)
    end

    it "should info without data, if no data was provided" do
      @iut.info("")
      expect(@iut.log.include?("info: ")).to eq(true)
    end
  end

  context "when given warn" do
    it "should warn with data received" do
      @iut.warn("test-warn")
      expect(@iut.log.include?("warn: test-warn")).to eq(true)
    end

    it "should warn without data, if no data was provided" do
      @iut.warn("")
      expect(@iut.log.include?("warn: ")).to eq(true)
    end
  end

  context "when given error" do
    it "should error with data received" do
      @iut.error("test-error")
      expect(@iut.log.include?("error: test-error")).to eq(true)
    end

    it "should error without data, if no data was provided" do
      @iut.error("")
      expect(@iut.log.include?("error: ")).to eq(true)
    end
  end

  context "when given fatal" do
    it "should fatal with data received" do
      @iut.fatal("test-fatal")
      expect(@iut.log.include?("fatal: test-fatal")).to eq(true)
    end

    it "should fatal without data, if no data was provided" do
      @iut.fatal("")
      expect(@iut.log.include?("fatal: ")).to eq(true)
    end
  end
end
