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
          style_guide = build_style_guide(config)
          file = build_file(code)

          violations = style_guide.file_review(file).violations

          violation = violations.first
          expect(violation.line_number).to eq 1
          expect(violation.messages).to include message
        end
      end
    end

    context "with custom configuration" do
      it "finds only one violation" do
        config = {
          "StringLiterals" => {
            "EnforcedStyle" => "double_quotes"
          }
        }

        violations = violations_with_config(config)

        expect(violations).to eq ["Use the new Ruby 1.9 hash syntax."]
      end

      it "can use custom configuration to display rubocop cop names" do
        config = { "AllCops" => { "DisplayCopNames" => "true" } }

        violations = violations_with_config(config)

        expect(violations).to eq [
          "Style/HashSyntax: Use the new Ruby 1.9 hash syntax."
        ]
      end

      context "with old-style syntax" do
        it "has one violation" do
          config = {
            "StringLiterals" => {
              "EnforcedStyle" => "single_quotes"
            },
            "HashSyntax" => {
              "EnforcedStyle" => "hash_rockets"
            },
          }

          violations = violations_with_config(config)

          expect(violations).to eq [
            "Prefer single-quoted strings when you don't need string "\
            "interpolation or special symbols."
          ]
        end
      end

      context "with using block" do
        it "returns violations" do
          violations = ["Pass `&:name` as an argument to `map` "\
                        "instead of a block."]

          expect(violations_in(<<-CODE)).to eq violations
  users.map do |user|
    user.name
  end
          CODE
        end
      end

      context "with calls debugger" do
        it "returns violations" do
          violations = ["Remove debugger entry point `binding.pry`."]

          expect(violations_in(<<-CODE)).to eq violations
  binding.pry
          CODE
        end
      end

      context "with empty lines around block" do
        it "returns violations" do
          violations = ["Extra empty line detected at block body beginning.",
                        "Extra empty line detected at block body end."]

          expect(violations_in(<<-CODE)).to eq violations
  block do |hoge|

    hoge

  end
          CODE
        end
      end

      context "with unnecessary space" do
        it "returns violations" do
          violations = ["Unnecessary spacing detected."]

          expect(violations_in(<<-CODE)).to eq violations
  hoge  = "https://github.com/bbatsov/rubocop"
  hoge
          CODE
        end
      end

      def violations_with_config(config)
        content = <<-TEXT.strip_heredoc
          def test_method
            { :foo => "hello world" }
          end
        TEXT

        violations_in(content, config: config)
      end
    end

    context "default configuration" do
      it "uses a default configuration for rubocop" do
        spy_on_rubocop_team
        spy_on_rubocop_configuration_loader
        config_file = default_configuration_file(StyleGuide::Ruby)
        code = <<-CODE
          private def foo
            bar
          end
        CODE

        violations_in(code, repository_owner_name: "not_thoughtbot")

        expect(RuboCop::ConfigLoader).to(
          have_received(:configuration_from_file).with(config_file)
        )

        expect(RuboCop::Cop::Team).to have_received(:new).
          with(anything, default_configuration, anything)
      end
    end

    context "thoughtbot organization PR" do
      it "uses the thoughtbot configuration for rubocop" do
        spy_on_rubocop_team
        spy_on_rubocop_configuration_loader
        config_file = thoughtbot_configuration_file(StyleGuide::Ruby)
        code = <<-CODE
          private def foo
            bar
          end
        CODE

        thoughtbot_violations_in(code)

        expect(RuboCop::ConfigLoader).to(
          have_received(:configuration_from_file).with(config_file)
        )

        expect(RuboCop::Cop::Team).to have_received(:new).
          with(anything, thoughtbot_configuration, anything)
      end

      describe "when using reduce" do
        it "returns no violations" do
          expect(thoughtbot_violations_in(<<-CODE)).to eq []
            users.reduce(0) do |sum, user|
              sum + user.age
            end
          CODE
        end
      end

      describe "when using inject" do
        it "returns violations" do
          violations = ["Prefer `reduce` over `inject`."]

          expect(thoughtbot_violations_in(<<-CODE)).to eq violations
            users.inject(0) do |_, user|
              user.age
            end
          CODE
        end
      end

      describe "when ommitting trailing commas" do
        it "returns violations" do
          violations = ["Put a comma after the last item of a multiline hash."]

          expect(thoughtbot_violations_in(<<-CODE)).to eq violations
            {
              a: 1,
              b: 2
            }
          CODE
        end
      end

      describe "when trailing commas are present" do
        it "returns no violations" do
          expect(thoughtbot_violations_in(<<-CODE)).to eq []
            {
              a: 1,
              b: 2,
            }
          CODE
        end
      end

      def thoughtbot_violations_in(content)
        violations_in(content, repository_owner_name: "thoughtbot")
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
          repo_config = double("RepoConfig", for: config)
          file = double("CommitFile", filename: "ignore.rb")
          style_guide = build_style_guide(repo_config: repo_config)

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
          repo_config = double("RepoConfig", for: config)
          file = double("CommitFile", filename: "app.rb")
          style_guide = build_style_guide(repo_config: repo_config)

          expect(style_guide.file_included?(file)).to eq true
        end
      end
    end

    private

    def violations_in(content, config: nil, repository_owner_name: "joe")
      repo_config = build_repo_config(config)
      style_guide = build_style_guide(
        repo_config: repo_config,
        repository_owner_name: repository_owner_name,
      )

      style_guide.
        file_review(build_file(content)).
        violations.
        flat_map(&:messages)
    end

    def build_style_guide(
      repo_config: build_repo_config,
      repository_owner_name: "not_thoughtbot"
    )
      StyleGuide::Ruby.new(
        repo_config: repo_config,
        build: build(:build),
        repository_owner_name: repository_owner_name,
      )
    end

    def build_repo_config(config = "")
      double("RepoConfig", enabled_for?: true, for: config)
    end

    def build_file(content)
      build_commit_file(filename: "app/models/user.rb", content: content)
    end

    def default_configuration
      config_file = default_configuration_file(StyleGuide::Ruby)
      RuboCop::ConfigLoader.configuration_from_file(config_file)
    end

    def thoughtbot_configuration
      config_file = thoughtbot_configuration_file(StyleGuide::Ruby)
      RuboCop::ConfigLoader.configuration_from_file(config_file)
    end

    def spy_on_rubocop_team
      allow(RuboCop::Cop::Team).to receive(:new).and_call_original
    end

    def spy_on_rubocop_configuration_loader
      allow(RuboCop::ConfigLoader).to receive(:configuration_from_file).
        and_call_original
    end
  end
end
