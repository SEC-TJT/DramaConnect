# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task default: :spec

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/intergration/api_spec.rb'
end

desc 'Tests Drama API specs only'
task :drama_spec do
  sh 'ruby spec/intergration/api_dramas_sepc.rb'
end

desc 'Tests Drama API specs only'
task :drama_list_spec do
  sh 'ruby spec/intergration/api_drama_lists_spec.rb'
end

desc 'Rerun tests on live code changes'
task :respec do
  sh 'rerun -c rake spec'
end

desc 'Tests API Intergration only'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/intergration/*_spec.rb'
  t.warning = false
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task style: %i[spec audit] do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task release?: %i[spec style audit] do
  puts "\nReady for release!"
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do
  require_app(nil) # loads config code files only
  require 'sequel'

  Sequel.extension :migration
  app = DramaConnect::Api

  desc 'Run migrations'
  task migrate: :print_env do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'app/db/migrations')
  end

  desc 'Delete database'
  task :delete do
    # app.DB[:dramas].delete
    # app.DB[:dramalists].delete
    DramaConnect::Account.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task :drop do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/db/store/#{DramaConnect::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end
end

namespace :newkey do
  desc 'Create sample cryptographic key for database'
  task :db do
    require_app('lib')
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end

namespace :run do
  # Run in development mode
  desc 'Run API in development mode'
  task :dev do
    sh 'puma -p 3000'
  end
end
