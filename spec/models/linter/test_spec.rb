require "spec_helper"
require "app/models/linter/base"

module Linter
  class Test < Base; end
end

describe Linter::Test do
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
