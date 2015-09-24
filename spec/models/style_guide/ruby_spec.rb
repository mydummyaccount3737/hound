require "rails_helper"

describe StyleGuide::Ruby do
  describe "#file_review" do
    it "returns a saved and completed file review" do
      style_guide = build_style_guide

      result = style_guide.file_review(build_file("test"))

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default configuration" do
      context "when double quotes are used" do
        it "returns violation" do
          message = "Prefer single-quoted strings when you don't need " +
            "string interpolation or special symbols."
          code = 'name = "Jim Tom"'

          violations = violations_with_config(code, config)

          expect(violations).to include message
        end
      end
    end

    context "with custom configuration" do
      it "finds a violation" do
        config = {
          "Style/StringLiterals" => {
            "EnforcedStyle" => "double_quotes"
          }
        }
        code = "name = 'Jim Tom'"
        message = "Prefer double-quoted strings unless you need single quotes "\
          "to avoid extra backslashes for escaping."

        violations = violations_with_config(code, config)

        expect(violations).to include message
      end

      it "can use custom configuration to display rubocop cop names" do
        config = { "AllCops" => { "DisplayCopNames" => "true" } }
        code = 'name = "Jim Tom"'
        message = "Style/StringLiterals: Prefer single-quoted strings when "\
          "you don't need string interpolation or special symbols."

        violations = violations_with_config(code, config)

        expect(violations).to include message
      end

      context "with old-style syntax" do
        it "finds a violation" do
          config = {
            "StringLiterals" => {
              "EnforcedStyle" => "double_quotes"
            }
          }
          code = "name = 'Jim Tom'"
          message = "Prefer double-quoted strings unless you need single "\
            "quotes to avoid extra backslashes for escaping."

          violations = violations_with_config(code, config)

          expect(violations).to include message
        end
      end
    end

    describe "#file_included?" do
      context "with excluded file" do
        it "returns false" do
          config = {
            "AllCops" => {
              "Exclude" => ["ignore.rb"]
            }
          }
          file = double("CommitFile", filename: "ignore.rb")
          style_guide = build_style_guide(config)

          expect(style_guide.file_included?(file)).to eq false
        end
      end

      context "with included file" do
        it "returns true" do
          config = {
            "AllCops" => {
              "Exclude" => []
            }
          }
          file = double("CommitFile", filename: "app.rb")
          style_guide = build_style_guide(config)

          expect(style_guide.file_included?(file)).to eq true
        end
      end
    end

    private

    def violations_with_config(code, config)
      violations_in(code, config: config)
    end

    def violations_in(content, config: nil)
      style_guide = build_style_guide(config)

      style_guide.
        file_review(build_file(content)).
        violations.
        flat_map(&:messages)
    end

    def build_file(content)
      build_commit_file(filename: "app/models/user.rb", content: content)
    end
  end
end
