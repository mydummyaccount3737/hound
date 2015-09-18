module Linter
  class Python < Base
    FILE_REGEXP = /.+\.py\z/
    JOB_CLASS = "python_review"
    LANGUAGE = "python"

    def file_review(commit_file)
      file_review = FileReview.create!(
        build: build,
        filename: commit_file.filename,
      )

      Resque.push(
        JOB_CLASS,
        {
          class: "review.PythonReviewJob",
          args: [
            commit_file.filename,
            build.commit_sha,
            build.pull_request_number,
            commit_file.patch,
            commit_file.content,
            repo_config.raw_for(LANGUAGE),
          ],
        }
      )

      file_review
    end
  end
end
