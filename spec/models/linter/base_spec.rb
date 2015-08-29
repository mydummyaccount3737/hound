require "spec_helper"
require "app/models/linter/base"

module Linter
  class Test < Base
    FILE_REGEXP = /.+\.yes\z/
  end
end

describe Linter::Base do
  describe ".lint?" do
    it "uses the FILE_REGEXP to determine the match" do
      result1 = Linter::Test.lint?("foo.yes")
      result2 = Linter::Test.lint?("foo.no")

      expect(result1).to eq true
      expect(result2).to eq false
    end
  end

  describe "#file_included?" do
    it "returns true" do
      style_guide = Linter::Test.new(
        repo_config: double,
        build: double,
        repository_owner_name: "foo",
      )

      expect(style_guide.file_included?(double)).to eq true
    end
  end
end
