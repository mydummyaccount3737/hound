require "rails_helper"

describe Linter do
  describe ".for" do
    context "given a ruby file" do
      it "returns the ruby linter" do
        filename = "hello.rb"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Ruby
      end
    end

    context "given a swift file" do
      it "returns the swift linter" do
        filename = "hello.swift"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Swift
      end
    end

    context "given a javascript file" do
      it "returns the javascript linter" do
        filename = "hello.js"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::JavaScript
      end
    end

    context "when a coffeescript file is given" do
      it "returns the coffeescript linter" do
        filename = "hello.coffee"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::CoffeeScript
      end

      it "supports `coffee.erb` as an extension" do
        filename = "hello.coffee.erb"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::CoffeeScript
      end

      it "supports `coffee.js` as an extension" do
        filename = "hello.coffee.js"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::CoffeeScript
      end
    end

    context "given a go file" do
      it "returns the go linter" do
        filename = "hello.go"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Go
      end
    end

    context "given a haml file" do
      it "returns the haml linter" do
        filename = "hello.haml"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Haml
      end
    end

    context "given a scss file" do
      it "returns the scss styelguide" do
        filename = "hello.scss"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Scss
      end
    end

    context "given a file that is unsupported" do
      it "returns the unsupported linter" do
        filename = "hello.whatever"

        klass = build_style_guide(filename: filename)

        expect(klass).to eq Linter::Unsupported
      end
    end
  end

  def build_style_guide(filename:)
    Linter.for(filename)
  end
end
