require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/*_test.rb"
end

Rake::RDocTask.new do |rdoc|
  files =['README.md', 'LICENSE'].concat(Dir.glob('lib/**/*.rb'))
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md"
  rdoc.title = "FastbillAutomatic Docs"
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers'
end

task :default => :test