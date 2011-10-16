spec = Gem::Specification.new do |s|
  s.name = "tiny_migration_lib"
  s.version = "0.1.0"
  s.authors = ["Graeme Hill"]
  s.email = "graemekh@gmail.com"
  s.homepage = "https://github.com/graeme-hill/tiny_migration_lib"
  s.platform = Gem::Platform::RUBY
  s.description = File.open("README").read
  s.summary = "A really, really simple SQL databiase migration library."
  s.files = ["README", "lib/tiny_migration_lib.rb", "test/tiny_migration_lib_tests.rb"]
  s.require_path = "lib"
  s.test_files = ["test/tiny_migration_lib_tests.rb"]
  s.extra_rdoc_files = ["README"]
  s.has_rdoc = true
end