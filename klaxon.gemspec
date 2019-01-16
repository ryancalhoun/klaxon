require_relative 'lib/klaxon/version'

Gem::Specification.new {|s|
  s.name = 'klaxon'
  s.version = Klaxon::VERSION
  s.licenses = ['MIT']
  s.summary = 'An interactive warning prompt for the command-line'
  s.description = 'Before a potentially dangerous or destructive action, issue a programmable warning prompt.'
  s.homepage = 'https://github.com/ryancalhoun/klaxon'
  s.authors = ['Ryan Calhoun']
  s.email = ['ryanjamescalhoun@gmail.com']
  
  s.files = Dir["{lib}/**/*"] + %w(README.md LICENSE)

  s.add_runtime_dependency 'artii', '~> 0'
  s.add_runtime_dependency 'colorize', '~> 0'
  s.add_runtime_dependency 'ruby-termino', '~> 0'
}
