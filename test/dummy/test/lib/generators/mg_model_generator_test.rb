require "test_helper"
require "generators/mg_model/mg_model_generator"

class MgModelGeneratorTest < Rails::Generators::TestCase
  tests MgModelGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
