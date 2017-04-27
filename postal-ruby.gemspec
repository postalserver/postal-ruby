require File.expand_path('../lib/postal/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "postal-ruby"
  s.description   = %q{Ruby library for the Postal e-mail platform}
  s.summary       = s.description
  s.homepage      = "https://github.com/atech/postal"
  s.version       = Postal::VERSION
  s.files         = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
  s.authors       = ["Adam Cooke"]
  s.email         = ["me@adamcooke.io"]
  s.licenses      = ['MIT']
  s.add_dependency "moonrope-client", ">= 1.0.2", "< 1.1"
end
