require 'logger'

require 'gem-checkout/source'
require 'gem-checkout/verifier'

class Gem::Commands::CheckoutCommand < Gem::Command
  def initialize
    super 'checkout', description
    add_option('-v', '--version VERSION', 'version to checkout') do |version, options|
      options[:version] = version
    end

    add_option('-d', '--debug LEVEL', 'set debug mode (0=debug)') do |level, options|
      options[:debug_level] = Integer(level)
    end

    add_option('-s', '--[no-]verify',  'verify sources match gem exactly') do |verify, options|
      options[:verify] = verify
    end
  end

  def arguments # :nodoc:
    "checkout        checkout the original repository at the same version"
  end

  def usage # :nodoc:
    "#{program_name}"
  end

  def defaults_str # :nodoc:
    ""
  end

  def description # :nodoc:
    "Checkout a gem's repository or sources at the same version"
  end

  def execute
    logger = Logger.new(STDERR)
    logger.level = options[:debug_level] || Logger::WARN
    Gem::Checkout.logger = logger

    name = get_one_gem_name
    source = Gem::Checkout::Source.new(name, options[:version])
    version = source.version

    repository = source.repository
    repository.clone(directory: name)
    Dir.chdir(name) do
      repository.checkout(source.source_reference)
      if options[:verify]
        verifier = Gem::Checkout::Verifier.new(name, version)
        verifier.verify!
      end
    end
  rescue Gem::Checkout::Repository::Error => ex
    alert_error ex.message
    terminate_interaction 1
  rescue Gem::Checkout::Verifier::Error => ex
    alert_error ex.message
    terminate_interaction 1
  end
end
