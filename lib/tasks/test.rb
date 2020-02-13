require 'rake/testtask'

desc 'Run test-unit based test'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test*.rb']
  t.verbose = true
  t.warning = true
end
