$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)
require 'byebug'
require 'logstash_auditor'
require 'logstash_auditor/auditor'
require 'elastic_search'
