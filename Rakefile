require "bundler/gem_tasks"
require "rake/testtask"
require "reissue/gem"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Reissue::Task.create :reissue do |task|
  task.version_file = "lib/direct/version.rb"
  task.changelog_file = "CHANGELOG.md"
  task.fragment = :git
end

task default: :test
