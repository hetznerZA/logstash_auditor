module LogstashAuditor

#TODO make the interface secure with  https://github.com/elastic/elasticsearch-ruby/blob/master/elasticsearch-transport/README.md

  class ElasticSearchTestAPI
    require 'elasticsearch'

    def initialize
      @client = Elasticsearch::Client.new log: false, host: '127.0.0.1:9200'
      @client.cluster.health
      @client.transport.reload_connections!
    end

    def search_for_flow_id(flow_id)
      @client.index  index: 'flow_id', type: 'my-document', id: 1, body: { title: 'flow_id' }
      @client.indices.refresh index: 'flow_id'
      result = @client.search index: '',
                              fields: ['message', 'flow_id'],
                              sort: { 'timestamp': { order: 'desc'}},
                              body:
                              {
                                query:
                                {
                                  match: { 'flow_id': flow_id}
                                }
                              }
      #TODO currently the search above searches all indexes.  Ideally we want to only search the flow_id index
      #TODO we are not yet certain that we are getting the latest event that matches this flow id
      if result["hits"]["total"] > 0
        return result["hits"]["hits"][0]["fields"]["message"][0]
      else
        return nil
      end
    end

    def create_flow_id
      return Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(4000000)}")
    end

  end
end
