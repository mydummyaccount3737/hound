module Linter
  class Scss < Base
    FILE_REGEXP = /.+\.scss\z/
    JOB_CLASS = ScssReviewJob
    LANGUAGE = "scss"
  end
end
