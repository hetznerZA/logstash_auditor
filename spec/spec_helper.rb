$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)
require 'byebug'
require 'elastic_search'
require 'logstash_auditor'
require 'logstash_auditor/auditor'

require 'soar_auditing_format'
