module Playwright
  define_api_implementation :AccessibilityImpl do
    def initialize(channel)
      @channel = channel
    end

    def snapshot(interestingOnly: nil, root: nil)
      params = {
        interestingOnly: interestingOnly,
        root: root&.channel,
      }.compact
      result = @channel.send_message_to_server('accessibilitySnapshot', params)
      format_ax_node_from_protocol(result) if result
      result
    end

    # original JS implementation create a new Hash from ax_node,
    # but this implementation directly modify ax_node and don't return hash.
    private def format_ax_node_from_protocol(ax_node)
      value = ax_node.delete('valueNumber') || ax_node.delete('valueString')
      ax_node['value'] = value unless value.nil?

      checked =
        case ax_node['checked']
        when 'checked'
          true
        when 'unchecked'
          false
        else
          ax_node['checked']
        end
      ax_node['checked'] = checked unless checked.nil?

      pressed =
        case ax_node['pressed']
        when 'pressed'
          true
        when 'released'
          false
        else
          ax_node['pressed']
        end
      ax_node['pressed'] = pressed unless pressed.nil?

      ax_node['children']&.each do |child|
        format_ax_node_from_protocol(child)
      end
    end
  end
end
