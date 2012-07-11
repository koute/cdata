Gem::Specification.new do |s|
  s.name        = 'cdata'
  s.version     = '1.0.2'
  s.date        = '2012-07-05'
  s.summary     = "C/C++ Data Serializer"
  s.description = "Serializes your Ruby data to static C++ structures you can use in your C++ code."
  s.authors     = ["Jan Bujak"]
  s.email       = 'j+cdata@jabster.pl'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage    = 'http://github.com/kouteiheika/cdata'
  s.require_paths = ["lib"]

  s.add_runtime_dependency "RubyInline"
end
