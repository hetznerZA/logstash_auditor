# SoarLogstashAuditor

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

## Usage


#TODO complete this section
#TODO Extend the SoarLogstashAuditor::AuditingProviderAPI to create an auditing provider:

```
class MyAuditingProvider < SoarLogstashAuditor::AuditingProviderAPI
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

class Log4rAuditingProvider < SoarLogstashAuditor::AuditingProviderAPI
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
