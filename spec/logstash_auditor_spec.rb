require 'spec_helper'

describe LogstashAuditor do
  before :all do
    @iut = LogstashAuditor::LogstashAuditor.new
    @invalid_logstash_configuration = { "bla" => "bla"}
    @valid_logstash_configuration = { "host_url" => "http://localhost:8080",
                              "use_ssl"  => false,
                              "username" => "something",
                              "password" => "something",
                              "timeout"  => 3}

    @iut.configure(@valid_logstash_configuration)

    @elasticsearch = LogstashAuditor::ElasticSearchTestAPI.new('http://localhost:9200')
  end

  it 'has a version number' do
    expect(LogstashAuditor::VERSION).not_to be nil
  end

  context "when configuring" do
    it 'should accept a valid auditor configuration' do
      expect(@iut.configuration_is_valid(@valid_logstash_configuration)).to eq(true)
    end

    it 'should reject an invalid auditor configuration' do
      expect(@iut.configuration_is_valid(@invalid_logstash_configuration)).to eq(false)
    end
  end

  context "when given audit" do
    it "should submit audit to logstash with data received" do
      #Create an unique test identifier that will be used to correlate the submitted test audit
      #with the located message in elastic search.
      test_identifier = @elasticsearch.create_test_id

      debug_message = "some audit event message"
      @iut.audit("rspec_testing:#{test_identifier}:#{Time.now.utc}:#{debug_message}")

      sleep(4) #Allow the event to be saved in Elastic Search before trying to search for it.

      found_event_message = @elasticsearch.search_for_test_id("rspec_testing:#{test_identifier}")
      expect(found_event_message).to be_truthy #Check if audit test identifier has been found
      expect(found_event_message.include?(debug_message)).to eq(true) #Check if the correct audit message was stored
    end

    it "should extract the level, flow, time and message fields on logstash server into separate fields"
  end
end
