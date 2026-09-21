ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Lets model tests attach files from test/fixtures/files, which is otherwise
    # only available to controller and integration tests.
    include ActionDispatch::TestProcess::FixtureFile

    # Add more helper methods to be used by all tests here...
  end
end
