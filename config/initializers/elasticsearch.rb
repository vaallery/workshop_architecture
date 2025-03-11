Searchkick.client = Elasticsearch::Client.new(hosts: [
  { host: ENV.fetch('ELASTIC_HOST', '127.0.0.1'),
    port: ENV.fetch('ELASTIC_PORT', '9200'),
    user: ENV.fetch('ELASTIC_USER', 'elastic'),
    password: ENV.fetch('ELASTIC_PASSWORD', 'admin'),
    scheme: ENV.fetch('ELASTIC_SCHEMA', 'http')
  } ]
)
