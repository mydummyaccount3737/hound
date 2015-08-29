module StyleGuide
  def self.for(filename)
    case filename
    when /.+\.rb\z/
      StyleGuide::Ruby
    when /.+\.coffee(\.js)?(\.erb)?\z/
      StyleGuide::CoffeeScript
    when /.+\.js\z/
      StyleGuide::JavaScript
    when /.+\.haml\z/
      StyleGuide::Haml
    when /.+\.scss\z/
      StyleGuide::Scss
    when /.+\.go\z/
      StyleGuide::Go
    when /.+\.py\z/
      StyleGuide::Python
    when /.+\.swift\z/
      StyleGuide::Swift
    else
      StyleGuide::Unsupported
    end
  end
end
