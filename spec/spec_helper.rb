$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)
require 'byebug'
require 'soar_logstash_auditor'
require 'soar_logstash_auditor/auditing_provider_api'
require 'support/test_api'
require 'support/test_auditor'
