module Linter
  class Markdown < Base
    LANGUAGE = "markdown"
    JOB_CLASS = MarkdownReviewJob
  end
end
