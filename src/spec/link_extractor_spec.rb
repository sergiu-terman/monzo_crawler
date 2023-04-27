describe "Aux::LinkExtractor" do
  describe "#extract" do
    it "extracts the links" do

      links = Aux::LinkExtractor.new.extract(%Q{
          <!DOCTYPE html>
          <html>
          <head>
            <title>Page Title</title>
          </head>
          <body>
            <h1>Heading 1</h1>
            <a href="https://monzo.com/">link</a>
            <a href="https://blog.monzo.com/">link</a>
            <a href="https://monzo.com/help#main">link</a>
            <a href="https://monzo.com/help">link</a>
            <a href="http://www.monzo.com/pots">link</a>
            <a href="http://www.monzo.com/pots?my=query">link</a>
            <a href="http://www.google.com">link</a>
          </body>
          </html>
                                             })
      expect(links.to_set).to eq(Set.new([
        "https://monzo.com/",
        "https://blog.monzo.com/",
        "https://monzo.com/help#main",
        "https://monzo.com/help",
        "http://www.monzo.com/pots",
        "http://www.monzo.com/pots?my=query",
        "http://www.google.com",
      ]))
    end
  end
end
