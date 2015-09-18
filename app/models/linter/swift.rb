module Linter
  class Swift < Base
    FILE_REGEXP = /.+\.swift\z/
    JOB_CLASS = SwiftReviewJob
    LANGUAGE = "swift"
  end
end
