module LogstashAuditor

  SEARCH_POLLING_MAXIMUM_WAIT  = 5   unless defined? SEARCH_POLLING_MAXIMUM_WAIT;  SEARCH_POLLING_MAXIMUM_WAIT.freeze
  SEARCH_POLLLING_INTERVAL     = 0.5 unless defined? SEARCH_POLLLING_INTERVAL;     SEARCH_POLLLING_INTERVAL.freeze

  class ElasticSearchTestAPI
    require 'elasticsearch'

    def initialize(url)
      @client = Elasticsearch::Client.new log: false, host: url
      @client.cluster.health
      @client.transport.reload_connections!
    end

    def create_flow_id
      return SecureRandom.hex(32)
    end

    def search_for_flow_id(flow_id)
      #Elastic search might take some time to process and make the audit available for searching
      total_busy_wait = 0
      found_event_message = nil
      while (total_busy_wait < SEARCH_POLLING_MAXIMUM_WAIT) and (found_event_message.nil?) do
        found_event_message = search(flow_id)
        sleep(SEARCH_POLLLING_INTERVAL) if found_event_message.nil?
        total_busy_wait += SEARCH_POLLLING_INTERVAL
      end
      return found_event_message
    end

    private

    def search(flow_id)
      @client.index  index: 'audit_flow_id', type: 'my-document', id: 1, body: { title: 'audit_flow_id' }
      @client.indices.refresh index: 'audit_flow_id'
      result = @client.search index: '',
                              fields: ['message', 'audit_flow_id'],
                              sort:
                              {
                                'timestamp': { order: 'desc'}
                              },
                              body:
                              {
                                query:
                                {
                                  match: { 'audit_flow_id': flow_id}
                                }
                              }
      if result["hits"]["total"] > 0
        return result["hits"]["hits"][0]["fields"]["message"][0]
      else
        return nil
      end
    end
  end
end
