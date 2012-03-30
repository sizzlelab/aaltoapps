require 'rubygems'

# allow the use of console-related gems given gems in rails console
# if they are installed in the normal load path
# (Bundler prevents loading from normal path if --path option is in use)
if ARGV.first =~ /^c(onsole)?$/
  %w[wirble irbtools wirb hirb].each do |lib|
    begin
      gem lib
    rescue Gem::LoadError
    end
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
