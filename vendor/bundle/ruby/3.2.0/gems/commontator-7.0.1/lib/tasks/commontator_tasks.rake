COMMONTATOR_COPY_TASKS = ['config/locales', 'app/assets/images',
                          'app/assets/stylesheets', 'app/views', 'app/mailers',
                          'app/helpers', 'app/controllers', 'app/models']

namespace :commontator do
  namespace :install do
    desc "Copy initializers from commontator to application"
    task :initializers do
      Dir.glob(File.expand_path('../../config/initializers/*.rb', __dir__)) do |file|
        if File.exist?(File.expand_path(File.basename(file), 'config/initializers'))
          print "NOTE: Initializer #{File.basename(file)} from commontator has been skipped. Initializer with the same name already exists.\n"
        else
          cp file, 'config/initializers', verbose: false
          print "Copied initializer #{File.basename(file)} from commontator\n"
        end
      end
    end
  end

  namespace :copy do
    COMMONTATOR_COPY_TASKS.each do |path|
      name = File.basename(path)
      desc "Copy #{name} from commontator to application"
      task name.to_sym do
        namespace = path.start_with?('app') ? '/commontator' : ''
        cp_r File.expand_path("../../#{path}#{namespace}", __dir__), path, verbose: false
        print "Copied #{name} from commontator\n"
      end
    end
  end

  desc "Copy initializers and migrations from commontator to application"
  task :install do
    Rake::Task["commontator:install:initializers"].invoke
    Rake::Task["commontator:install:migrations"].invoke
  end

  desc "Copy assets, views, mailers, helpers, controllers and models from commontator to application"
  task :copy do
    COMMONTATOR_COPY_TASKS.each do |path|
      Rake::Task["commontator:copy:#{File.basename(path)}"].invoke
    end
  end
end
