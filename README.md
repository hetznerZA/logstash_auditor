# LogstashAuditor

This gem provides the logstash auditor that can be plugged into the SOAR architecture. The auditor supports basic and certifcate based authentication to the logstash http input.  Privacy can be ensured by simply using an tls tunnel.

## State of the API

This auditor is to be extended with NFR support pending behavioural specifications.
Note that the interface for auditors is still not completely stable and therefore subject to change.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logstash_auditor'
```

And then execute:

```bash
  bundle
```

Or install it yourself as:

```bash
  gem install logstash_auditor
  ```

## Configuration of Logstash Server

The logstash server must be configured using the configuration in the folder spec/support/logstash_conf.d and spec/support/certificates.
This configuration is used by the docker image during the TDD tests which ensures that this gem and the server configuration is compatible.

## Testing

Behavioural driven testing can be performed by testing against a local ELK docker image.

First you need to generate the certificates needed for authenticating the client to the server and the server itself.

```bash
  ./spec/support/certificates/setup_certificates_for_logstash_testing.sh
```

Start a docker container with the ELK stack:

```bash
  docker run -d --name elk_test_service -v $(pwd)/spec/support/logstash_conf.d:/etc/logstash/conf.d -v $(pwd)/spec/support/certificates:/etc/logstash/certs -p 9090:9090 -p 9300:9300 -p 9200:9200 -p 5000:5000 -p 5044:5044 -p 5601:5601 -p 8081:8080 sebp/elk
```

Wait about 30 seconds for image to fire up. Then perform the tests:

```bash
  bundle exec rspec -cfd spec/*
```

Note that in order to ensure that the processing has occurred on Elastic Search
there is a 2 second delay between each event submission request and the search request

Debugging the docker image:
```bash
  docker exec -it elk_test_service bash
  docker stop elk_test_service
  docker rm -f elk_test_service
```

Manual sending of an audit event to docker ELK stack:
```bash
  curl -iv -E ./spec/support/certificates/selfsigned/selfsigned_registered.cert.pem --key ./spec/support/certificates/selfsigned/selfsigned_registered.private.nopass.pem https://localhost:8081 -d "message=soar_logstash_test" --insecure
```

View the audit events created on the Kibana interface:

```bash
  http://localhost:5601/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-15m,mode:quick,to:now))&_a=(columns:!(_source),index:'*',interval:auto,query:(query_string:(analyze_wildcard:!t,query:'*')),sort:!('@timestamp',desc))
```

## Usage

Initialize and configure the auditor so:

```ruby
@iut = LogstashAuditor::LogstashAuditor.new
@logstash_configuration =
{ "host_url" => "http://localhost:8081",
  "username" => "auditorusername",
  "password" => "auditorpassword",
  "timeout"  => 3}
@iut.configure(@logstash_configuration)
```

Audit using the API methods inherited from SoarAuditorApi::AuditorAPI, e.g.:

```ruby
@iut.warn("This is a test event")
```

## Detailed example

```ruby
require 'logstash_auditor'
require 'soar_auditing_format'
require 'time'
require 'securerandom'

class Main
  def test_sanity
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration =
    { "host_url" => "http://localhost:8080",
      "username" => "auditorusername",
      "password" => "auditorpassword",
      "timeout"  => 3}
    @iut.configure(@logstash_configuration)
    @iut.set_audit_level(:debug)

    my_optional_operation_field = SoarAuditingFormatter::Formatter.optional_field_format("operation", "Http.Get")
    my_optional_method_name_field = SoarAuditingFormatter::Formatter.optional_field_format("method", "#{self.class}::#{__method__}::#{__LINE__}")
    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"#{my_optional_method_name_field}#{my_optional_operation_field} test message with optional fields"))
  end
end

main = Main.new
main.test_sanity
```

## Contributing

Bug reports and feature requests are welcome by email to barney dot de dot villiers at hetzner dot co dot za. This gem is sponsored by Hetzner (Pty) Ltd (http://hetzner.co.za)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
