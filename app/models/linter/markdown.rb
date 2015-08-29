module Linter
  class Markdown < Base
    FILE_REGEXP = /.+(?:\.md|\.markdown)\z/
    NAME = "markdown"
  end
end
