require "rails_helper"

describe Linter::Markdown do
  describe ".lint?" do
    context "given a .md file" do
      it "returns true" do
        result = Linter::Markdown.lint?("foo.md")

        expect(result).to eq true
      end
    end

    context "given a .markdown file" do
      it "returns true" do
        result = Linter::Markdown.lint?("foo.markdown")

        expect(result).to eq true
      end
    end

    context "given a non-markdown file" do
      it "returns true" do
        result = Linter::Markdown.lint?("foo.txt")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file(filename: "README.md")

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      style_guide = build_style_guide("config", build)
      commit_file = build_commit_file(filename: "doc/SECURITY.md")
      allow(Resque).to receive(:enqueue)

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        MarkdownReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config",
      )
    end
  end
end
