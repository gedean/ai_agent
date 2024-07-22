Gem::Specification.new do |s|
  s.name          = 'intelli_agent'
  s.version       = '0.0.1'
  s.date          = '2024-07-22'
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'AI Agent'
  s.description   = 'AI Agent.'
  s.authors       = ['Gedean Dias']
  s.email         = 'gedean.dias@gmail.com'
  s.files         = Dir['README.md', 'lib/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3'
  s.homepage      = 'https://github.com/gedean/intelli_agent'
  s.license       = 'MIT'
  s.add_dependency 'ruby-openai', '~> 7.1'
  s.post_install_message = %q{Please check readme file for use instructions.}
end
