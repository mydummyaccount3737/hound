require "rails_helper"

describe StyleGuide::Haml do
  let(:filename) { "app/views/show.html.haml" }

  describe "#file_review" do
    it "returns a saved and completed file review" do
      style_guide = build_style_guide({})
      file = build_file("")

      result = style_guide.file_review(file)

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default configuration" do
      context "with an implicit %div violation" do
        it "returns violations" do
          content = "%div#container Hello"
          message = "`%div#container` can be written as `#container` since "\
            "`%div` is implicit"

          expect(violations_in(content)).to include message
        end
      end
    end

    context "with custom configuration" do
      context "when explicit div is allowed" do
        it "does not find violations" do
          content = "%div#container Hello"
          config = {
            "linters" => {
              "ImplicitDiv" => {
                "enabled" => false
              }
            }
          }
          message = "`%div#container` can be written as `#container` since "\
            "`%div` is implicit"

          expect(violations_in(content, config)).not_to include message
        end
      end

      context "when explicit div is not allowed" do
        it "finds violations" do
          content = "%div#container Hello"
          config = {
            "linters" => {
              "ImplicitDiv" => {
                "enabled" => true
              }
            }
          }

          message = "`%div#container` can be written as `#container` since "\
            "`%div` is implicit"

          expect(violations_in(content, config)).to include message
        end
      end
    end

    context "when linter excludes a file" do
      it "does not return violations" do
        config = {
          "linters" => {
            "ClassesBeforeIds" => {
              "enabled" => true,
              "exclude" => filename,
            }
          }
        }
        content = "%div#bar.foo\n"

        expect(violations_in(content, config)).not_to be_empty
      end
    end
  end

  describe "#file_included?" do
    context "with excluded file" do
      it "returns false" do
        config = { "exclude" => filename }
        style_guide = build_style_guide(config)

        expect(style_guide.file_included?(filename)).to eq false
      end
    end

    context "with non-excluded file" do
      it "returns true" do
        config = { "exclude" => "app/views/clearance/**" }
        style_guide = build_style_guide(config)

        expect(style_guide.file_included?(filename)).to eq true
      end
    end
  end

  private

  def violations_in(content, config = {})
    style_guide = build_style_guide(config)
    style_guide.file_review(build_file(content)).violations.
      flat_map(&:messages)
  end

  def build_file(content)
    build_commit_file(filename: filename, content: content)
  end
end
