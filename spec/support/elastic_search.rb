module LogstashAuditor

  class ElasticSearchTestAPI
    require 'elasticsearch'

    def initialize(url)
      @client = Elasticsearch::Client.new log: false, host: url
      @client.cluster.health
      @client.transport.reload_connections!
    end

    def search_for_flow_id(flow_id)
      @client.index  index: 'audit_flow_id', type: 'my-document', id: 1, body: { title: 'audit_flow_id' }
      @client.indices.refresh index: 'flow_id'
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

    def create_flow_id
      return Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(9999999)}")
    end

  end
end
