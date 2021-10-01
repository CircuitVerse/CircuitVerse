module ActivityNotification
  class DummyCommonController < ActivityNotification.config.parent_controller.constantize
    include CommonController
  end
end
