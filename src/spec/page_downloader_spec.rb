describe "Task::PageDownloader" do
  Response = Struct.new(:code, :body)

  before :each do
    allow(Aux::Log).to receive(:info)

    @publisher = double("publisher")
    @content_writer = double("content_writer")

    @page = Model::Page.create(
      url: "https://monzo.com/",
      domain: Model::Domain.create(
        name: "monzo",
        domain_filter: "monzo.com",
        seed: "https://monzo.com/",
      )
    )
  end

  after :each do
    Aux::DbUtil.clean!
  end

  context "download fails" do

    before do
      @web_getter = double("web_getter", get: Response.new(416))
    end

    it "records the failure to the model" do
      Task::PageDownloader.new(@page, @publisher, @web_getter, @content_writer).run_internal

      p = Model::Page.all.first

      expect(p.download_failed).to be(true)
      expect(p.download_name).to be(nil)
      expect(p.is_downloaded).to be(true)
      expect(p.downloaded_at).not_to be(nil)
    end

    it "does not send a message to the publisher nor write the content" do
      expect(@publisher).not_to receive(:publish)
      expect(@content_writer).not_to receive(:write)

      Task::PageDownloader.new(@page, @publisher, @web_getter, @content_writer).run_internal
    end
  end

  context "download succeeds" do
    before do
      @web_getter = double("web_getter", get: Response.new(200, "<html/>"))
    end


    it "records and publishes the success" do
      expect(@publisher).to receive(:publish).with(@page)
      expect(@content_writer).to receive(:write).with(any_args, "<html/>")

      Task::PageDownloader.new(@page, @publisher, @web_getter, @content_writer).run_internal

      p = Model::Page.all.first

      expect(p.download_failed).to be(false)
      expect(p.download_name).to start_with("monzo_")
      expect(p.is_downloaded).to be(true)
      expect(p.downloaded_at).not_to be(nil)
    end
  end
end
