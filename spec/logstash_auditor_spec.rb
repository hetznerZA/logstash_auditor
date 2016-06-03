require 'spec_helper'

describe LogstashAuditor do
  before :all do
    @iut = LogstashAuditor::LogstashAuditor.new
    @invalid_logstash_configuration = { "foo" => "bar"}
    @valid_logstash_configuration = { "host_url" => "http://localhost:8081",
                                      "username" => "auditorusername",
                                      "password" => "auditorpassword",
                                      "timeout"  => 3}
    @iut.configure(@valid_logstash_configuration)
    @elasticsearch = LogstashAuditor::ElasticSearchTestAPI.new('http://localhost:9200')
  end

  it 'has a version number' do
    expect(LogstashAuditor::VERSION).not_to be nil
  end

  context "when extending from AuditorAPI" do
    it 'should adhere to auditor api by not preventing exceptions' do
      expect {
        @iut.configure(@invalid_logstash_configuration)
      }.to raise_error(ArgumentError, "Invalid configuration provided")
      expect {
        @iut.set_audit_level(:something)
      }.to raise_error(ArgumentError, "Invalid audit level specified")
    end

    it 'has a method audit' do
      expect(@iut.respond_to?('audit')).to eq(true)
    end

    it 'has a method configuration_is_valid?' do
      expect(@iut.respond_to?('configuration_is_valid?')).to eq(true)
    end
  end

  context "when configured by AuditorAPI" do
    it 'should accept a valid configuration' do
      expect(@iut.configuration_is_valid?(@valid_logstash_configuration)).to eq(true)
    end

    it 'should reject an invalid configuration' do
      expect(@iut.configuration_is_valid?(@invalid_logstash_configuration)).to eq(false)
    end
  end

  context "when asked by AuditorAPI to audit" do
    it "should submit audit to logstash with data received" do
      #Create an unique test flow_id that will be used to correlate the submitted test audit
      #with the audit found by elastic search.
      flow_id = @elasticsearch.create_flow_id

      my_optional_field = SoarAuditingFormatter::Formatter.optional_field_format("somekey", "somevalue")
      debug_message = "#{my_optional_field} some audit event message"

      @iut.audit(SoarAuditingFormatter::Formatter.format(:debug,'my-rspec-service-id',flow_id,Time.now,debug_message))
      found_event_message = @elasticsearch.search_for_flow_id(flow_id)

      expect(found_event_message).to be_truthy #Check if audit test flow_id has been found
      expect(found_event_message.include?(debug_message)).to eq(true) #Check if the correct audit message was stored
    end

    it "should raise StandardError if logstash connection fails, given incorrect port" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "http://localhost:9090"))
        @iut.audit("message")
      }.to raise_error(StandardError, 'Failed to create connection')
    end

    it "should raise StandardError if logstash connection fails, given incorrect host" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "http://somewhere:8081"))
        @iut.audit("message")
      }.to raise_error(StandardError, 'Failed to create connection')
    end

    it "should raise StandardError if logstash authentication fails" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("username" => "wrongauditorusername"))
        @iut.audit("message")
      }.to raise_error(StandardError, "Server rejected post with error code 401")
    end

    it "should raise StandardError if a timeout occurs trying to establish a connection" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("timeout" => 0))
        @iut.audit("message with zero timeout")
      }.to raise_error(StandardError, 'Failed to create connection')
    end

    it "should raise StandardError if an error occurs on the server" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("username" => "wrongauditorusername"))
        @iut.audit("message")
      }.to raise_error(StandardError, "Server rejected post with error code 401")
    end

    it "should raise StandardError if a local error occurs trying to establish a connection" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "unknownprotocolandhosturl"))
        @iut.audit("message")
      }.to raise_error(StandardError, 'Failed to create connection')
    end

    it "should raise StandardError if logstash connection is refused" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "http://localhost:9090"))
        @iut.audit("message")
      }.to raise_error(StandardError, 'Failed to create connection')
    end
  end
end
