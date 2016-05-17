require 'spec_helper'

describe LogstashAuditor do
  before :all do
    @iut = LogstashAuditor::LogstashAuditor.new
    @invalid_logstash_configuration = { "bla" => "bla"}
    @valid_logstash_configuration = { "host_url" => "http://127.0.0.1:8080",
                             "username" => "something",
                             "password" => "something",
                             "timeout"  => 3}
    @iut.configure(@valid_logstash_configuration)

    elastic_search_configuration = { "host_url" => "http://localhost:9200/_search",
                                     "username" => "something",
                                     "password" => "something",
                                     "timeout"  => 3}
    @elasticsearch = LogstashAuditor::ElasticSearchTestAPI.new
  end

  it 'has a version number' do
    expect(LogstashAuditor::VERSION).not_to be nil
  end

  context "when initializing" do
    it 'should accept a valid auditor configuration' do
      @iut.configure(@valid_logstash_configuration)
      expect(@iut.has_been_configured).to eq(true)
    end

    it 'should raise ArgumentError if no configuration is specified' do
      expect {
        @iut.configure(nil)
      }.to raise_error(ArgumentError, "No configuration provided")
    end

    it 'should raise ArgumentError if invalid configuration is specified' do
      expect {
        @iut.configure(@invalid_logstash_configuration)
      }.to raise_error(ArgumentError, "Invalid configuration provided")
    end
  end

  context "when given event" do
    it "should submit event to logstash with data received" do
      test_id = @elasticsearch.create_flow_id
      debug_message = "some debug message"

      @iut.event(test_id, debug_message)
      sleep(2) #Allow the event to be saved in Elastic Search before trying to search for it.
      found_event_message = @elasticsearch.search_for_flow_id(test_id)

      expect(found_event_message).to be_truthy #Not nil
      expect(found_event_message.include?(debug_message)).to eq(true)
    end

    it "should submit event without data, if no data was provided" do
      test_id = @elasticsearch.create_flow_id
      debug_message = ""

      @iut.event(test_id, debug_message)
      sleep(2) #Allow the event to be saved in Elastic Search before trying to search for it.
      found_event_message = @elasticsearch.search_for_flow_id(test_id)

      expect(found_event_message).to be_truthy #Not nil
      expect(found_event_message.include?(debug_message)).to eq(true)
    end
  end
end
