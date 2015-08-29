module Linter
  class Python < Base
    FILE_REGEXP = /.+\.py\z/
    NAME = "python"

    private

    def enqueue_job(attributes)
      Resque.push(
        "python_review",
        {
          args: [attributes],
        }
      )
    end
  end
end
