# LogstashAuditor

This gem provides the logstash auditing provider for the SOAR architecture.

The provider adheres to the soar auditing API as set out below.

## State of the API

This provider is to be extended with NFR support pending behavioural specifications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'soar_logstash_auditor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install soar_logstash_auditor

## Testing

Behavioural driven testing can be performed by testing against an ELK docker image:

    $ sudo docker run -d -v spec/support/logstash_conf.d:/etc/logstash/conf.d -p 9300:9300 -p 9200:9200 -p 5000:5000 -p 5044:5044 -p 5601:5601 -p 8080:8080 sebp/elk
    $ bundle exec rspec -cfd spec/*

Note that in order to ensure that the processing has occurred on Elastic Search
there is a 2 second delay between each event submission request and the search request

Afterwards destroy the running docker image as follows:
    $ sudo docker ps
    $ sudo docker <CONTAINER_ID>

## Usage


#TODO complete this section
#TODO Extend the LogstashAuditor::AuditingProviderAPI to create an auditing provider:

```
class MyAuditingProvider < LogstashAuditor::AuditingProviderAPI
end
```

Provide the required inversion of control method to configure (an) injected auditor(s):

```
def configure_auditor(configuration = nil)
  @auditor.configure(configuration)
end
```

Initialize the provider so:

```
auditor = MyAuditor.new
auditor_configuration = { 'some' => 'configuration' }
@iut = MyAuditingProvider.new(auditor, auditor_configuration)
```

Audit using the API methods, e.g.:

```
@iut.info("This is info")
@iut.debug(some_debug_object)
@iut.warn("Statistics show that dropped packets have increased to #{dropped}%")
@iut.error("Could not resend some dropped packets. They have been lost. All is still OK, I could compensate")
@iut.fatal("Unable to perform action, too many dropped packets. Functional degradation.")
@iut << 'Rack::CommonLogger requires this'
```

The API also supports appending as below, enabling support, e.g. for Rack::CommonLogger, etc.:

```
<<
```

## Detailed example

```
require 'log4r'
require 'soar_logstash_auditor'

class Log4rAuditingProvider < LogstashAuditor::AuditingProviderAPI
  def configure_auditor(configuration = nil)
    @auditor.outputters = configuration['outputter']
  end
end

class Main
  include Log4r

  def test_sanity
    auditor = Logger.new 'sanity'
    auditor_configuration = { 'outputter' => Outputter.stdout }
    @iut = Log4rAuditingProvider.new(auditor, auditor_configuration)

    some_debug_object = 123
    @iut.info("This is info")
    @iut.debug(some_debug_object)
    dropped = 95
    @iut.warn("Statistics show that dropped packets have increased to #{dropped}%")
    @iut.error("Could not resend some dropped packets. They have been lost. All is still OK, I could compensate")
    @iut.fatal("Unable to perform action, too many dropped packets. Functional degradation.")
  end
end

main = Main.new
main.test_sanity
```

## Contributing

Bug reports and feature requests are welcome by email to barney dot de dot villiers at hetzner dot co dot za. This gem is sponsored by Hetzner (Pty) Ltd (http://hetzner.co.za)

## Notes

Though out of scope for the provider, auditors should take into account encoding, serialization, and other NFRs.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
