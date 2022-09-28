namespace 'dynamo_db' do
  namespace 'session_store' do
    desc 'Clean up old sessions in the Amazon DynamoDB session store table.'
    task clean: :environment do
      Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage
    end
  end
end
