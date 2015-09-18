require "spec_helper"
require "app/models/linter/base"

module Linter
  class Test < Base
    FILE_REGEXP = //
  end
end

describe Linter::Base do
  describe ".lint?" do
    it "uses the FILE_REGEXP to determine the match" do
      result = Linter::Test.lint?("foo.bar")

      expect(result).to eq true
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
