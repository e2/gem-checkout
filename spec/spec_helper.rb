RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  # config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.before do
    if Object.const_defined?(:Gems)
      allow(Gems).to receive(:versions) do |*args|
        fail "stub called: Gems.versions(#{args.map(&:inspect) * ','})"
      end

      allow(Gems).to receive(:info) do |*args|
        fail "stub called: Gems.info(#{args.map(&:inspect) * ','})"
      end
    end

    allow(Gem::Specification).to receive(:find_by_name) do |*args|
      fail "stub called: Gem::Specification.find_by_name(#{args.map(&:inspect) * ','})"
    end
  end
end
