describe "Aux::FileManager" do

  before do
    @test_dir = "/tmp/cralwer_test"
    Dir.mkdir(@test_dir)
    @subject = Aux::FileManager.new
    allow(@subject).to receive(:dir_path).and_return(@test_dir)
  end

  after do
    FileUtils.rm_rf(@test_dir)
  end

  describe "#write and #read" do
    it "writes the content that can be read" do
      @subject.write("test", "<html/>")
      content = @subject.read("test")
      expect(content).to eq("<html/>")
    end
  end
end
