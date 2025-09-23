module Playwright
  define_channel_owner :Tracing do
    def start(name: nil, title: nil, screenshots: nil, snapshots: nil, sources: nil)
      params = {
        name: name,
        screenshots: screenshots,
        snapshots: snapshots,
        sources: sources,
      }.compact
      @include_sources = params[:sources] || false
      @channel.send_message_to_server('tracingStart', params)
      trace_name = @channel.send_message_to_server('tracingStartChunk', { title: title, name: name }.compact)
      start_collecting_stacks(trace_name)
    end

    def start_chunk(title: nil, name: nil)
      trace_name = @channel.send_message_to_server('tracingStartChunk', { title: title, name: name }.compact)
      start_collecting_stacks(trace_name)
    end

    private def start_collecting_stacks(trace_name)
      unless @is_tracing
        @is_tracing = true
        @connection.set_in_tracing(true)
      end
      @stacks_id = @connection.local_utils.tracing_started(@traces_dir, trace_name)
    end

    def stop_chunk(path: nil)
      do_stop_chunk(file_path: path)
    end

    def stop(path: nil)
      do_stop_chunk(file_path: path)
      @channel.send_message_to_server('tracingStop')
    end

    private def do_stop_chunk(file_path:)
      if @is_tracing
        @is_tracing = false
        @connection.set_in_tracing(false)
      end

      unless file_path
        # Not interested in any artifacts
        @channel.send_message_to_server('tracingStopChunk', mode: 'discard')
        if @stacks_id
          @connection.local_utils.trace_discarded(@stacks_id)
        end

        return
      end

      unless @connection.remote?
        result = @channel.send_message_to_server_result('tracingStopChunk', mode: 'entries')
        @connection.local_utils.zip(
          zipFile: file_path,
          entries: result['entries'],
          stacksId: @stacks_id,
          mode: 'write',
          includeSources: @include_sources,
        )

        return
      end


      result = @channel.send_message_to_server_result('tracingStopChunk', mode: 'archive')
      # The artifact may be missing if the browser closed while stopping tracing.
      unless result['artifact']
        if @stacks_id
          @connection.local_utils.trace_discarded(@stacks_id)
        end

        return
      end

      # Save trace to the final local file.
      artifact = ChannelOwners::Artifact.from(result['artifact'])
      artifact.save_as(file_path)
      artifact.delete

      @connection.local_utils.zip(
        zipFile: file_path,
        entries: [],
        stacksId: @stacks_id,
        mode: 'append',
        includeSources: @include_sources,
      )
    end

    private def update_traces_dir(traces_dir)
      @traces_dir = traces_dir
    end

    def group(name, location: nil)
      params = {
        name: name,
        location: location,
      }.compact
      @channel.send_message_to_server('tracingGroup', params)
    end

    def group_end
      @channel.send_message_to_server('tracingGroupEnd')
    end
  end
end
