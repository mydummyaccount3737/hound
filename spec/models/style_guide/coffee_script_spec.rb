require "rails_helper"

describe StyleGuide::CoffeeScript do
  describe "#file_review" do
    it "returns a saved and completed file review" do
      style_guide = build_style_guide_with_default_config
      file = build_file("foo")

      result = style_guide.file_review(file)

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default configuration" do
      context "for long line" do
        it "returns file review with violations" do
          style_guide = build_style_guide_with_default_config
          file = build_file("1" * 81)

          violations = style_guide.file_review(file).violations

          violation = violations.first
          expect(violation.line_number).to eq 1
          expect(violation.messages).to include("Line exceeds maximum allowed length")
        end
      end
    end

    context "with custom configuration" do
      context "when line length is configured" do
        it "does not find line length violation" do
          config = {
            "max_line_length": {
              "value": 81
            }
          }
          style_guide = build_style_guide(config)
          file = build_file("1" * 81)

          violations = style_guide.file_review(file).violations

          messages = violations.flat_map(&:messages)
          expect(messages).not_to include("Line exceeds maximum allowed length")
        end
      end
    end

    context "given a `coffee.erb` file" do
      it "returns file review with violations" do
        style_guide = build_style_guide_with_default_config
        file = build_file("class strange_ClassNAME", "test.coffee.erb")

        violations = style_guide.file_review(file).violations

        violation = violations.first
        expect(violation.line_number).to eq 1
        expect(violation.messages).to(
          include("Class name should be UpperCamelCased")
        )
      end

      it "removes the ERB tags from the file" do
        style_guide = build_style_guide_with_default_config
        content = "leonidasLastWords = <%= raise 'hell' %>"
        file = build_file(content, "test.coffee.erb")

        violations = style_guide.file_review(file).violations

        expect(violations).to be_empty
      end
    end

    def build_style_guide_with_default_config
      build_style_guide({})
    end

    def build_file(content, filename = "test.coffee")
      build_commit_file(filename: filename, content: content)
    end
  end
end
