module Commontator::BuildThread
  def commontator_thread
    @commontator_thread ||= super
    return @commontator_thread unless @commontator_thread.nil?

    @commontator_thread = build_commontator_thread.tap do |thread|
      thread.save if persisted?
    end
  end
end
