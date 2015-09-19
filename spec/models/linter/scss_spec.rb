require "rails_helper"

describe Linter::Scss do
  describe ".lint?" do
    context "given an .scss file" do
      it "returns true" do
        result = Linter::Scss.lint?("foo.scss")

        expect(result).to eq true
      end
    end

    context "given a non-scss file" do
      it "returns false" do
        result = Linter::Scss.lint?("foo.css")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      style_guide = build_style_guide
      commit_file = build_commit_file(filename: "lib/a.scss")

      result = style_guide.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      style_guide = build_style_guide("config", build)
      commit_file = build_commit_file(filename: "lib/a.scss")
      allow(Resque).to receive(:enqueue)

      style_guide.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config"
      )
    end
  end
end
