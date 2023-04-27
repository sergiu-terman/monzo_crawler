describe "model setup" do
  before :context do
    @domain = Model::Domain.create(
      name: "Monzo",
      domain_filter: "monzo.com",
      seed: "https://monzo.com/",
    )

    @home_page = Model::Page.create(
      url: "https://monzo.com/",
      domain: @domain,
    )

    @help_page = Model::Page.create(
      url: "https://monzo.com/help",
      domain: @domain,
    )

    Model::PageToPage.create(
      source: @home_page,
      destination: @help_page,
    )
  end

  it "has domains poiting to pages" do
    expect(@domain.pages.count).to eq(2)
  end

  it "links between pages" do
    dest_pages = @home_page.linked_to

    expect(dest_pages.count).to eq(1)
    expect(dest_pages.first.url).to eq(@help_page.url)
  end
end
