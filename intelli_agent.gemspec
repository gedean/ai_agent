Gem::Specification.new do |s|
  s.name          = 'intelli_agent'
  s.version       = '0.2.9'
  s.date          = '2027-10-03'
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'A helper layer over Anthropic and OpenAI API'
  s.description   = 'Adds helpers modules, classes and methods to make it easier to use Anthropic and OpenAI API'
  s.authors       = ['Gedean Dias']
  s.email         = 'gedean.dias@gmail.com'
  s.files         = Dir['README.md', 'lib/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3'
  s.homepage      = 'https://github.com/gedean/intelli_agent'
  s.license       = 'MIT'
  s.add_dependency 'ruby-openai', '~> 7.1'
  s.add_dependency 'anthropic', '~> 0.3'
  s.add_dependency 'oj', '~> 3'
  s.post_install_message = %q{Please check readme file for use instructions.}
end
