module Linter
  def self.for(filename)
    case filename
    when /.+\.rb\z/
      Linter::Ruby
    when /.+\.coffee(\.js)?(\.erb)?\z/
      Linter::CoffeeScript
    when /.+\.js\z/
      Linter::JavaScript
    when /.+\.haml\z/
      Linter::Haml
    when /.+\.scss\z/
      Linter::Scss
    when /.+\.go\z/
      Linter::Go
    when /.+\.py\z/
      Linter::Python
    when /.+\.swift\z/
      Linter::Swift
    else
      Linter::Unsupported
    end
  end
end
