namespace :sunspot do

  desc "Drop and then reindex all solr models that are located in your application's models directory."
  # This task depends on the standard Rails file naming \
  # conventions, in that the file name matches the defined class name. \
  # By default the indexing system works in batches of 50 records, you can \
  # set your own value for this by using the batch_size argument. You can \
  # also optionally define a list of models separated by a plus sign '+'
  #
  # $ rake sunspot:reindex                # reindex all models
  # $ rake sunspot:reindex[1000]          # reindex in batches of 1000
  # $ rake sunspot:reindex[false]         # reindex without batching
  # $ rake sunspot:reindex[,Post]         # reindex only the Post model
  # $ rake sunspot:reindex[1000,Post]     # reindex only the Post model in
  #                                       # batchs of 1000
  # $ rake sunspot:reindex[,Post+Author]  # reindex Post and Author model
  task :reindex, [:batch_size, :models, :silence] => [:environment] do |t, args|
    # Retry once or gracefully fail for a 5xx error so we don't break reindexing
    with_session(Sunspot::SessionProxy::Retry5xxSessionProxy.new(Sunspot.session)) do

      # Set up general options for reindexing
      reindex_options = { :batch_commit => false }

      case args[:batch_size]
      when 'false'
        reindex_options[:batch_size] = nil
      when /^\d+$/
        reindex_options[:batch_size] = args[:batch_size].to_i if args[:batch_size].to_i > 0
      end

      # Load all the application's models. Models which invoke 'searchable' will register themselves
      # in Sunspot.searchable.
      Rails.application.eager_load!
      Rails::Engine.subclasses.each{|engine| engine.instance.eager_load!}

      if args[:models].present?
        # Choose a specific subset of models, if requested
        model_names = args[:models].split(/[+ ]/)
        sunspot_models = model_names.map{ |m| m.constantize }
      else
        # By default, reindex all searchable models
        sunspot_models = Sunspot.searchable
      end

      # Set up progress_bar to, ah, report progress unless the user has chosen to silence output
      begin
        require 'progress_bar'
        total_documents = sunspot_models.map { | m | m.count }.sum
        reindex_options[:progress_bar] = ProgressBar.new(total_documents)
      rescue LoadError => e
        $stdout.puts "Skipping progress bar: for progress reporting, add gem 'progress_bar' to your Gemfile"
      rescue ProgressBar::ArgumentError => e
        $stdout.puts "You have no data in the database. Reindexing does nothing here."
      rescue Exception => e
        $stderr.puts "Error using progress bar: #{e.message}"
      end unless args[:silence]

      # Finally, invoke the class-level solr_reindex on each model
      sunspot_models.each do |model|
        model.solr_reindex(reindex_options)
      end
    end
  end

  # Swaps sunspot sessions for the duration of the block
  # Ensures the session is returned to normal in case this task is called from within the rails app
  # and not just a one-off from the command line
  def with_session(new_session)
    original_session = Sunspot.session
    Sunspot.session = new_session
    yield
  ensure
    Sunspot.session = original_session
  end

  def sunspot_solr_in_load_path?
    # http://www.rubular.com/r/rJGDh7eOSc
    $:.any? { |path| path.to_s =~ %r{sunspot_solr(-[^/]+)?/lib$} }
  end

  unless sunspot_solr_in_load_path?
    namespace :solr do
      task :moved_to_sunspot_solr do
        abort %(
  Note: This task has been moved to the sunspot_solr gem. To install, start and
  stop a local Solr instance, please add sunspot_solr to your Gemfile:

  group :development do
    gem 'sunspot_solr'
  end

)
      end

      desc 'Start the Solr instance'
      task :start => :moved_to_sunspot_solr

      desc 'Run the Solr instance in the foreground'
      task :run => :moved_to_sunspot_solr

      desc 'Stop the Solr instance'
      task :stop => :moved_to_sunspot_solr

      # for backwards compatibility
      task :reindex => :"sunspot:reindex"
    end
  end
end
