require 'controllers/dummy_common_controller'

describe ActivityNotification::DummyCommonController, type: :controller do

  describe "#set_index_options" do
    it "raises NotImplementedError" do
      expect { controller.send(:set_index_options) }
        .to raise_error(NotImplementedError, /You have to implement .+#set_index_options/)
    end
  end

  describe "#load_index" do
    it "raises NotImplementedError" do
      expect { controller.send(:load_index) }
        .to raise_error(NotImplementedError, /You have to implement .+#load_index/)
    end
  end

  describe "#controller_path" do
    it "raises NotImplementedError" do
      expect { controller.send(:controller_path) }
        .to raise_error(NotImplementedError, /You have to implement .+#controller_path/)
    end
  end
end