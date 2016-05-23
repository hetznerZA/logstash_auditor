module LogstashAuditor

  class ElasticSearchTestAPI
    require 'elasticsearch'

    def initialize(url)
      @client = Elasticsearch::Client.new log: false, host: url
      @client.cluster.health
      @client.transport.reload_connections!
    end

    def search_for_test_id(test_id)
      @client.index  index: 'message', type: 'my-document', id: 1, body: { title: 'message' }
      @client.indices.refresh index: 'message'
      result = @client.search index: '',
                              fields: ['message'],
                              sort:
                              {
                                'timestamp': { order: 'desc'}
                              },
                              body:
                              {
                                query:
                                {
                                  match: { 'message': "*#{test_id}*"}
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

    def create_test_id
      return Digest::SHA256.hexdigest("#{Time.now.to_i}#{rand(4000000)}")
    end

  end
end
