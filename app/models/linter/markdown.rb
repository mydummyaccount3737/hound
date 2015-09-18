module Linter
  class Markdown < Base
    FILE_REGEXP = /.+(?:\.md|\.markdown)\z/
    JOB_CLASS = MarkdownReviewJob
    LANGUAGE = "markdown"
  end
end
