# LogstashAuditor

This gem provides the logstash auditor that can be plugged into the SOAR architecture.

## State of the API

This auditor is to be extended with NFR support pending behavioural specifications.
Note that the interface for auditors is still not completely stable and therefore subject to change.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logstash_auditor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logstash_auditor

## Testing

Behavioural driven testing can be performed by testing against a local ELK docker image:

    $ sudo docker run -d -v $(pwd)/spec/support/logstash_conf.d:/etc/logstash/conf.d -p 9300:9300 -p 9200:9200 -p 5000:5000 -p 5044:5044 -p 5601:5601 -p 8080:8080 sebp/elk

Wait about 30 seconds for image to fire up. Then perform the tests:

    $ bundle exec rspec -cfd spec/*

Note that in order to ensure that the processing has occurred on Elastic Search
there is a 2 second delay between each event submission request and the search request

Afterwards destroy the running docker image as follows:
    $ sudo docker ps
    $ sudo docker stop <CONTAINER_ID>

Debugging the docker image:
    $ sudo docker exec -it <CONTAINER_ID> bash

## Usage

Initialize and configure the auditor so:

```ruby
@iut = LogstashAuditor::LogstashAuditor.new
@logstash_configuration =
{ "host_url" => "http://localhost:8080",
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
require 'time'

class Main
  def test_sanity
    @iut = LogstashAuditor::LogstashAuditor.new
    @logstash_configuration =
    { "host_url" => "http://localhost:8080",
      "username" => "auditorusername",
      "password" => "auditorpassword",
      "timeout"  => 3}
    @iut.configure(@logstash_configuration)

    require 'digest'
    flow_id = Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(4000000)}")

    @iut.warn("#{flow_id}:#{Time.now.utc.iso8601(3)}:test1234")
  end
end

main = Main.new
main.test_sanity
```

## Contributing

Bug reports and feature requests are welcome by email to barney dot de dot villiers at hetzner dot co dot za. This gem is sponsored by Hetzner (Pty) Ltd (http://hetzner.co.za)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
