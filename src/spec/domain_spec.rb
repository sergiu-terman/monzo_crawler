describe "Model::Domain" do
  before :each do
    @domain = Model::Domain.create(
      name: "Monzo",
      domain_filter: "monzo.com",
      seed: "https://monzo.com/",
    )
  end

  after :each do
    Aux::DbUtil.clean!
  end

  describe "#has_pages?" do

    it "returns true when it has pages" do
      Model::Page.create(
        url: "https://monzo.com/",
        domain: @domain,
      )

      expect(@domain.has_pages?).to be(true)
    end

    it "returns false when it has no pages" do
      expect(@domain.has_pages?).to be(false)
    end
  end

  describe "#pages_to_download" do
    describe "there is a page that was not downloaded" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
        )
      end

      it "returns the page that was not downloaded" do
        expect(@domain.pages_to_download.count).to eq(1)
      end
    end

    describe "there is page that was already downloaded" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
          is_downloaded: true,
        )
      end

      it "returns an empty list" do
        expect(@domain.pages_to_download).to be_empty
      end
    end
  end

  describe "#pages_to_parse" do
    describe "is_downloaded = false, is_parsed = false" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
        )
      end

      it "returns an empty list" do
        expect(@domain.pages_to_parse).to be_empty
      end
    end

    describe "is_downloaded = true, is_parsed = false" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
          is_downloaded: true,
        )
      end

      it "returns the page" do
        expect(@domain.pages_to_parse.count).to eq(1)
      end
    end

    describe "is_downloaded = true, is_parsed = true" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
          is_downloaded: true,
          is_parsed: true,
        )
      end

      it "returns an empty list" do
        expect(@domain.pages_to_parse).to be_empty
      end
    end

    describe "is_downloaded = false, is_parsed = true (this shoul not happen)" do
      before :each do
        Model::Page.create(
          url: "https://monzo.com/",
          domain: @domain,
          is_parsed: true,
        )
      end

      it "returns an empty list" do
        expect(@domain.pages_to_parse).to be_empty
      end
    end
  end

end
