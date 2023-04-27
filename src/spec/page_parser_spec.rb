describe "Task::PageParser" do
  before do
    allow(Aux::Log).to receive(:info)

    domain = Model::Domain.create(
      name: "monzo",
      domain_filter: "monzo.com",
      seed: "https://monzo.com/",
    )

    @page = Model::Page.create(
      url: "https://monzo.com/",
      domain: domain,
    )

    @link_extractor = double("link_extractor", extract: [
      "https://monzo.com/",                 # bad (already present)
      "https://blog.monzo.com/",            # bad (domain missmatch)
      "https://monzo.com/help#main",        # ok
      "https://monzo.com/help",             # bad (help page already recorded)
      "http://www.monzo.com/pots",          # ok
      "http://www.monzo.com/pots?my=query", # ok
      "http://www.google.com",              # bad
    ])
    @publisher = double("publisher")

    # the content doesn't matter since the link extractor is mocked as well
    @content_reader = double("content_reader", read: "<html/>")
  end

  it "extracts, filtres, saves and publishes the new links" do
    expect(@publisher).to receive(:publish).with(any_args).exactly(3).times

    Task::PageParser.new(@page, @publisher, @link_extractor, @content_reader).run
    @page.reload

    other_pages = @page.linked_to
    other_pages_urls = other_pages.map{ |p| p.url }
    expect(other_pages.count).to eq(3)
    expect(other_pages_urls.to_set).to eq(Set.new([
      "https://monzo.com/help",
      "http://www.monzo.com/pots",
      "http://www.monzo.com/pots?my=query",
    ]))
    expect(@page.is_parsed).to be(true)
    expect(@page.parsed_at).not_to be(nil)
  end
end
