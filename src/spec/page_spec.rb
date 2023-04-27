describe "Model::Page" do
  before :each do
    @domain = Model::Domain.create(
      name: "Monzo",
      domain_filter: "monzo.com",
      seed: "https://monzo.com/",
    )

    @page = Model::Page.create(
      url: "https://monzo.com/",
      domain: @domain,
    )
  end

  after :each do
    Aux::DbUtil.clean!
  end

  describe "#record_failed_download!" do

    it "marks the download failure fields" do
      @page.record_failed_download!

      p = Model::Page.all.first

      expect(p.is_downloaded).to be(true)
      expect(p.download_failed).to be(true)
      expect(p.downloaded_at).not_to be(nil)
    end
  end

  describe "#record_download!" do
    it "saves the download file name" do
      @page.record_download!("the_download_path")

      p = Model::Page.all.first

      expect(p.is_downloaded).to be(true)
      expect(p.download_failed).to be(false)
      expect(p.downloaded_at).not_to be(nil)
      expect(p.download_name).to eq("the_download_path")
    end
  end
end
