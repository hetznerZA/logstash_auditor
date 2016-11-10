require 'spec_helper'

describe LogstashAuditor do
  before :each do
    @iut = LogstashAuditor::LogstashAuditor.new
    @invalid_logstash_configuration = { "foo" => "bar"}
    @valid_certificate_auth_logstash_configuration = { "host_url"    => "https://localhost:8081",
                                                       "certificate"  => File.read("spec/support/certificates/selfsigned/selfsigned_registered.cert.pem"),
                                                       "private_key" => File.read("spec/support/certificates/selfsigned/selfsigned_registered.private.nopass.pem"),
                                                       "timeout"     => 3}
    @valid_unregistered_certificate_auth_logstash_configuration = { "host_url"    => "https://localhost:8081",
                                                                    "certificate"  => File.read("spec/support/certificates/selfsigned/selfsigned_unregistered.cert.pem"),
                                                                    "private_key" => File.read("spec/support/certificates/selfsigned/selfsigned_unregistered.private.nopass.pem"),
                                                                    "timeout"     => 3}
    @valid_basic_auth_logstash_configuration = { "host_url" => "https://localhost:8081",
                                                 "username" => "auditorusername",
                                                 "password" => "auditorpassword",
                                                 "timeout"  => 3}
    @valid_certificate_auth_and_tcp_logstash_configuration = { "host_url"    => "tcp://localhost:9090",
                                                               "certificate"  => File.read("spec/support/certificates/selfsigned/selfsigned_registered.cert.pem"),
                                                               "private_key" => File.read("spec/support/certificates/selfsigned/selfsigned_registered.private.nopass.pem"),
                                                               "timeout"     => 3}
    @valid_logstash_configuration = @valid_certificate_auth_logstash_configuration
    @iut.configure(@valid_logstash_configuration)
    @elasticsearch = LogstashAuditor::ElasticSearchTestAPI.new('http://localhost:9200')
  end

  after :each do
    @iut.instance_variable_set(:@http,nil)
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
    it 'should accept a valid basic authentication configuration' do
      expect(@iut.configuration_is_valid?(@valid_basic_auth_logstash_configuration)).to eq(true)
    end

    it 'should accept a valid certificate based authentication configuration' do
      expect(@iut.configuration_is_valid?(@valid_certificate_auth_logstash_configuration)).to eq(true)
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

    it "should submit multiple audits to logstash with when multiple audits are recevied" do
      my_optional_field = SoarAuditingFormatter::Formatter.optional_field_format("somekey", "somevalue")
      debug_message = "#{my_optional_field} some audit event message"

      flow_id1 = @elasticsearch.create_flow_id
      @iut.audit(SoarAuditingFormatter::Formatter.format(:debug,'my-rspec-service-id',flow_id1,Time.now,debug_message))
      flow_id2 = @elasticsearch.create_flow_id
      @iut.audit(SoarAuditingFormatter::Formatter.format(:debug,'my-rspec-service-id',flow_id2,Time.now,debug_message))

      found_event_message = @elasticsearch.search_for_flow_id(flow_id1)
      expect(found_event_message).to be_truthy #Check if audit test flow_id has been found
      expect(found_event_message.include?(debug_message)).to eq(true) #Check if the correct audit message was stored

      found_event_message = @elasticsearch.search_for_flow_id(flow_id2)
      expect(found_event_message).to be_truthy #Check if audit test flow_id has been found
      expect(found_event_message.include?(debug_message)).to eq(true) #Check if the correct audit message was stored
    end

    it "should not take long to submit multiple events to logstash using http" do
      debug_message = "some audit event message"

      last_flow_id = nil
      iterations = 10
      test_start_time = Time.now
      expect(Timeout::timeout(20) do
        iterations.times { |x|
          iteration_start_time = Time.now
          last_flow_id = @elasticsearch.create_flow_id
          @iut.audit(SoarAuditingFormatter::Formatter.format(:debug,'my-rspec-service-id',last_flow_id,Time.now,debug_message))
          iteration_time_delta = Time.now - iteration_start_time
          $stderr.puts "Http Iteration #{x}/#{iterations} : Time delta = #{iteration_time_delta}"
        }
        true
      end).to eq(true)
      test_time_delta = Time.now - test_start_time
      $stderr.puts "Http Test Time Delta = #{test_time_delta}"

      found_event_message = @elasticsearch.search_for_flow_id(last_flow_id)
      expect(found_event_message).to be_truthy #Check if audit test flow_id has been found
      expect(found_event_message.include?(debug_message)).to eq(true) #Check if the correct audit message was stored
    end

    it "should not take long to submit multiple events to logstash using tcp" do
      @iut = LogstashAuditor::LogstashAuditor.new
      @iut.configure(@valid_certificate_auth_and_tcp_logstash_configuration)

      debug_message = "some audit event message"

      last_flow_id = nil
      iterations = 10
      test_start_time = Time.now
      expect(Timeout::timeout(20) do
        iterations.times { |x|
          iteration_start_time = Time.now
          last_flow_id = @elasticsearch.create_flow_id
          @iut.audit(SoarAuditingFormatter::Formatter.format(:debug,'my-rspec-service-id',last_flow_id,Time.now,debug_message))
          iteration_time_delta = Time.now - iteration_start_time
          $stderr.puts "Tcp Iteration #{x}/#{iterations} : Time delta = #{iteration_time_delta}"
        }
        true
      end).to eq(true)
      test_time_delta = Time.now - test_start_time
      $stderr.puts "Tcp Test Time Delta = #{test_time_delta}"

      found_event_message = @elasticsearch.search_for_flow_id(last_flow_id)
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
        @iut.configure(@valid_unregistered_certificate_auth_logstash_configuration)
        @iut.audit("message")
      }.to raise_error(StandardError, "Failed to create connection")
    end

    it "should raise StandardError if a timeout occurs trying to establish a connection" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("timeout" => 0))
        @iut.audit("message with zero timeout")
      }.to raise_error(StandardError, 'Failed to create connection')
    end

    it "should raise StandardError if an error occurs on the server" do
      expect {
        @iut.configure(@valid_unregistered_certificate_auth_logstash_configuration)
        @iut.audit("message")
      }.to raise_error(StandardError, "Failed to create connection")
    end

    it "should raise StandardError if a local error occurs trying to establish a connection" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "unknownprotocolandhosturl"))
        @iut.audit("message")
      }.to raise_error(StandardError)
    end

    it "should raise StandardError if logstash connection is refused" do
      expect {
        @iut.configure(@valid_logstash_configuration.dup.merge("host_url" => "http://localhost:9090"))
        @iut.audit("message")
      }.to raise_error(StandardError, 'Failed to create connection')
    end
  end
end
