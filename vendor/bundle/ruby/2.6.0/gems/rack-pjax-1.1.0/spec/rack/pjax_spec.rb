require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Rack::Pjax do
  include Rack::Test::Methods # can be moved to config

  def generate_app(options={})
    body = options[:body]

    Rack::Lint.new(
      Rack::Pjax.new(
        lambda do |env|
          [
            200,
            {'Content-Type' => 'text/plain', 'Content-Length' => body.bytesize.to_s},
            [body]
          ]
        end
      )
    )
  end

  context "a pjaxified app, upon receiving a pjax-request" do
    before do
      self.class.app = generate_app(:body => '<html><title>Hello</title><body><div data-pjax-container>World!</div></body></html>')
    end

    it "should return the title-tag in the body" do
      get "/", {}, {"HTTP_X_PJAX" => "true"}
      expect(body).to eq("<title>Hello</title>World!")
    end

    it "should return the inner-html of the pjax-container in the body" do
      self.class.app = generate_app(:body => '<html><body><div data-pjax-container>World!</div></body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true"}
      expect(body).to eq("World!")
    end

    it "should return the inner-html of the custom pjax-container in the body" do
      self.class.app = generate_app(:body => '<html><body><div id="container">World!</div></body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true", "HTTP_X_PJAX_CONTAINER" => "#container"}
      expect(body).to eq("World!")
    end

    it "should handle self closing tags with HTML5 elements" do
      self.class.app = generate_app(:body => '<html><body><div data-pjax-container><article>World!<img src="test.jpg" /></article></div></body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true"}

      expect(body).to eq('<article>World!<img src="test.jpg"></article>')
    end

    it "should handle nesting of elements inside anchor tags" do
      self.class.app = generate_app(:body => '<html><body><div data-pjax-container><a href="#"><h1>World!</h1></a></div></body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true"}

      expect(body).to eq('<a href="#"><h1>World!</h1></a>')
    end

    it "should handle html5 br tags correctly" do
      self.class.app = generate_app(:body => '<html><body><div data-pjax-container><p>foo<br>bar</p></div></body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true"}

      expect(body).to eq('<p>foo<br>bar</p>')
    end

    it "should handle frozen body string correctly" do
      self.class.app = generate_app(:body => '<html><body><div data-pjax-container><p>foo<br>bar</p></div></body></html>'.freeze)

      get "/", {}, {"HTTP_X_PJAX" => "true"}

      expect(body).to eq('<p>foo<br>bar</p>')
    end

    it "should return the correct Content Length" do
      get "/", {}, {"HTTP_X_PJAX" => "true"}
      expect(headers['Content-Length']).to eq(body.bytesize.to_s)
    end

    it "should return the original body when there's no pjax-container" do
      self.class.app = generate_app(:body => '<html><body>Has no pjax-container</body></html>')

      get "/", {}, {"HTTP_X_PJAX" => "true"}
      expect(body).to eq("<html><body>Has no pjax-container</body></html>")
    end

    it "should preserve whitespaces of the original body" do
      container = "\n <p>\nfirst paragraph</p> <p>Second paragraph</p>\n"
      self.class.app = generate_app(:body =><<-BODY)
<html>
<div data-pjax-container>#{container}</div>
</html>
BODY

      get "/", {}, {"HTTP_X_PJAX" => "true"}
      expect(body).to eq(container)
    end
  end

  context "a pjaxified app, upon receiving a non-pjax request" do
    before do
      self.class.app = generate_app(:body => '<html><title>Hello</title><body><div data-pjax-container>World!</div></body></html>')
    end

    it "should return the original body" do
      get "/"
      expect(body).to eq('<html><title>Hello</title><body><div data-pjax-container>World!</div></body></html>')
    end

    it "should return the correct Content Length" do
      get "/"
      expect(headers['Content-Length']).to eq(body.bytesize.to_s)
    end
  end
end
