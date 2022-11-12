require "spec_helper"

describe Paperclip::Style do
  context "A style rule" do
    before do
      @attachment = attachment path: ":basename.:extension",
                               styles: { foo: { geometry: "100x100#", format: :png } },
                               whiny: true
      @style = @attachment.styles[:foo]
    end

    it "is held as a Style object" do
      expect(@style).to be_a Paperclip::Style
    end

    it "gets processors from the attachment definition" do
      assert_equal [:thumbnail], @style.processors
    end

    it "has the right geometry" do
      assert_equal "100x100#", @style.geometry
    end

    it "is whiny if the attachment is" do
      assert @style.whiny?
    end

    it "responds to hash notation" do
      assert_equal [:thumbnail], @style[:processors]
      assert_equal "100x100#", @style[:geometry]
    end

    it "returns the name of the style in processor options" do
      assert_equal :foo, @style.processor_options[:style]
    end
  end

  context "A style rule with properties supplied as procs" do
    before do
      @attachment = attachment path: ":basename.:extension",
                               whiny_thumbnails: true,
                               processors: lambda { |_a| [:test] },
                               styles: {
                                 foo: lambda { |_a| "300x300#" },
                                 bar: {
                                   geometry: lambda { |_a| "300x300#" },
                                   convert_options: lambda { |_a| "-do_stuff" },
                                   source_file_options: lambda { |_a| "-do_extra_stuff" }
                                 }
                               }
    end

    it "calls procs when they are needed" do
      assert_equal "300x300#", @attachment.styles[:foo].geometry
      assert_equal "300x300#", @attachment.styles[:bar].geometry
      assert_equal [:test], @attachment.styles[:foo].processors
      assert_equal [:test], @attachment.styles[:bar].processors
      assert_equal "-do_stuff", @attachment.styles[:bar].convert_options
      assert_equal "-do_extra_stuff", @attachment.styles[:bar].source_file_options
    end
  end

  context "An attachment with style rules in various forms" do
    before do
      styles = {}
      styles[:aslist] = ["100x100", :png]
      styles[:ashash] = { geometry: "100x100", format: :png }
      styles[:asstring] = "100x100"
      @attachment = attachment path: ":basename.:extension",
                               styles: styles
    end

    it "has the right number of styles" do
      expect(@attachment.styles).to be_a Hash
      assert_equal 3, @attachment.styles.size
    end

    it "has styles as Style objects" do
      [:aslist, :ashash, :aslist].each do |s|
        expect(@attachment.styles[s]).to be_a Paperclip::Style
      end
    end

    it "has the right geometries" do
      [:aslist, :ashash, :aslist].each do |s|
        assert_equal @attachment.styles[s].geometry, "100x100"
      end
    end

    it "has the right formats" do
      assert_equal @attachment.styles[:aslist].format, :png
      assert_equal @attachment.styles[:ashash].format, :png
      assert_nil @attachment.styles[:asstring].format
    end

    it "retains order" do
      assert_equal [:aslist, :ashash, :asstring], @attachment.styles.keys
    end
  end

  context "An attachment with :convert_options" do
    it "does not have called extra_options_for(:thumb/:large) on initialization" do
      @attachment = attachment path: ":basename.:extension",
                               styles: { thumb: "100x100", large: "400x400" },
                               convert_options: { all: "-do_stuff", thumb: "-thumbnailize" }
      expect(@attachment).to_not receive(:extra_options_for)
      @style = @attachment.styles[:thumb]
    end

    it "calls extra_options_for(:thumb/:large) when convert options are requested" do
      @attachment = attachment path: ":basename.:extension",
                               styles: { thumb: "100x100", large: "400x400" },
                               convert_options: { all: "-do_stuff", thumb: "-thumbnailize" }
      @style = @attachment.styles[:thumb]
      @file = StringIO.new("...")
      allow(@file).to receive(:original_filename).and_return("file.jpg")

      expect(@attachment).to receive(:extra_options_for).with(:thumb)
      @attachment.styles[:thumb].convert_options
    end
  end

  context "An attachment with :source_file_options" do
    it "does not have called extra_source_file_options_for(:thumb/:large) on initialization" do
      @attachment = attachment path: ":basename.:extension",
                               styles: { thumb: "100x100", large: "400x400" },
                               source_file_options: { all: "-density 400", thumb: "-depth 8" }
      expect(@attachment).to_not receive(:extra_source_file_options_for)
      @style = @attachment.styles[:thumb]
    end

    it "calls extra_options_for(:thumb/:large) when convert options are requested" do
      @attachment = attachment path: ":basename.:extension",
                               styles: { thumb: "100x100", large: "400x400" },
                               source_file_options: { all: "-density 400", thumb: "-depth 8" }
      @style = @attachment.styles[:thumb]
      @file = StringIO.new("...")
      allow(@file).to receive(:original_filename).and_return("file.jpg")

      expect(@attachment).to receive(:extra_source_file_options_for).with(:thumb)
      @attachment.styles[:thumb].source_file_options
    end
  end

  context "A style rule with its own :processors" do
    before do
      @attachment = attachment path: ":basename.:extension",
                               styles: {
                                 foo: {
                                   geometry: "100x100#",
                                   format: :png,
                                   processors: [:test]
                                 }
                               },
                               processors: [:thumbnail]
      @style = @attachment.styles[:foo]
    end

    it "does not get processors from the attachment" do
      expect(@attachment).to_not receive(:processors)
      assert_not_equal [:thumbnail], @style.processors
    end

    it "reports its own processors" do
      assert_equal [:test], @style.processors
    end
  end

  context "A style rule with :processors supplied as procs" do
    before do
      @attachment = attachment path: ":basename.:extension",
                               styles: {
                                 foo: {
                                   geometry: "100x100#",
                                   format: :png,
                                   processors: lambda { |_a| [:test] }
                                 }
                               },
                               processors: [:thumbnail]
    end

    it "defers processing of procs until they are needed" do
      expect(@attachment.styles[:foo].instance_variable_get("@processors")).to be_a Proc
    end

    it "calls procs when they are needed" do
      assert_equal [:test], @attachment.styles[:foo].processors
    end
  end

  context "An attachment with :convert_options and :source_file_options in :styles" do
    before do
      @attachment = attachment path: ":basename.:extension",
                               styles: {
                                 thumb: "100x100",
                                 large: { geometry: "400x400",
                                          convert_options: "-do_stuff",
                                          source_file_options: "-do_extra_stuff" }
                               }
      @file = StringIO.new("...")
      allow(@file).to receive(:original_filename).and_return("file.jpg")
    end

    it "has empty options for :thumb style" do
      assert_equal "", @attachment.styles[:thumb].processor_options[:convert_options]
      assert_equal "", @attachment.styles[:thumb].processor_options[:source_file_options]
    end

    it "has the right options for :large style" do
      assert_equal "-do_stuff", @attachment.styles[:large].processor_options[:convert_options]
      assert_equal "-do_extra_stuff", @attachment.styles[:large].processor_options[:source_file_options]
    end
  end

  context "A style rule supplied with default format" do
    before do
      @attachment = attachment default_format: :png,
                               styles: {
                                 asstring: "300x300#",
                                 aslist: ["300x300#", :jpg],
                                 ashash: {
                                   geometry: "300x300#",
                                   convert_options: "-do_stuff"
                                 }
                               }
    end

    it "has the right number of styles" do
      expect(@attachment.styles).to be_a Hash
      assert_equal 3, @attachment.styles.size
    end

    it "has styles as Style objects" do
      [:aslist, :ashash, :aslist].each do |s|
        expect(@attachment.styles[s]).to be_a Paperclip::Style
      end
    end

    it "has the right geometries" do
      [:aslist, :ashash, :aslist].each do |s|
        assert_equal @attachment.styles[s].geometry, "300x300#"
      end
    end

    it "has the right formats" do
      assert_equal @attachment.styles[:aslist].format,    :jpg
      assert_equal @attachment.styles[:ashash].format,    :png
      assert_equal @attachment.styles[:asstring].format,  :png
    end
  end
end
