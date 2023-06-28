module IMS::LTI
  module Extensions

    # An LTI extension that adds support for content back to the consumer
    #
    #     # Initialize TP object with OAuth creds and post parameters
    #     provider = IMS::LTI::ToolProvider.new(consumer_key, consumer_secret, params)
    #     # add extension
    #     provider.extend IMS::LTI::Extensions::Content::ToolProvider
    #
    # If the tool was launched as an content request and it supports the content extension
    # you can redirect the user to the tool consumer using the return url helper methods.
    # The tool consumer is then responsible for consuming the content.
    #
    #     #Check if a certain response type is available
    #     if provider.accepts_url? do
    #       #Generate the URL for the user
    #       redirect provider.url_content_return_url(url)
    #     end
    #
    module Content
      module ToolProvider
        include IMS::LTI::Extensions::ExtensionBase
        include Base

        # a list of the supported outcome data types
        def accepted_content_types
          return @content_types if @content_types
          @content_types = []
          if val = @ext_params["content_return_types"]
            @content_types = val.split(',').map {|i| i.to_sym}
          end

          @content_types
        end

        def accepted_file_extensions
          return @file_extensions if @file_extensions
          @file_extensions = []
          if val = @ext_params["content_file_extensions"]
            @file_extensions = val.split(',').map {|i| i.downcase.strip}
          end

          @file_extensions
        end

        def accepts_file?(file_name = nil)
          accepted_content_types.include?(:file) &&
            ( file_name.nil? ||
              accepted_file_extensions.empty? ||
              accepted_file_extensions.any?{|ext| file_name.downcase[/#{ext}$/]} )
        end

        def accepts_url?
          accepted_content_types.include?(:url)
        end

        def accepts_lti_launch_url?
          accepted_content_types.include?(:lti_launch_url)
        end

        def accepts_image_url?
          accepted_content_types.include?(:image_url)
        end

        def accepts_iframe?
          accepted_content_types.include?(:iframe)
        end

        def accepts_oembed?
          accepted_content_types.include?(:oembed)
        end

        def content_intended_use
          @ext_params["content_intended_use"].to_sym if  @ext_params["content_intended_use"]
        end

        # check if the content extension is supported
        def accepts_content?
          !!@ext_params["content_return_types"]
        end

        # check if the consumer accepts a given type of content
        def accepts_content_type?(content_type)
          accepted_content_types.include? content_type.to_sym
        end

        #check the use of the content
        def is_content_for? (intended_use)
          content_intended_use == intended_use
        end

        def content_return_url
          @ext_params["content_return_url"]
        end

        #generates the return url for file submissions
        def file_content_return_url(url, text, content_type = nil)
          url = CGI::escape(url)
          text = CGI::escape(text)
          content_type = CGI::escape(content_type) if content_type

          return_url = "#{content_return_url}?return_type=file&url=#{url}&text=#{text}"
          return_url = "#{return_url}&content_type=#{content_type}" if content_type

          return return_url
        end

        #generates the return url for url submissions
        def url_content_return_url(url, title = nil, text = 'link', target = '_blank')
          url = CGI::escape(url)
          text = CGI::escape(text)
          target = CGI::escape(target)

          return_url = "#{content_return_url}?return_type=url&url=#{url}&text=#{text}&target=#{target}"
          return_url = "#{return_url}&title=#{CGI::escape(title)}" if title

          return return_url
        end

        #generates the return url for lti launch submissions
        def lti_launch_content_return_url(url, text='link', title=nil)
          url = CGI::escape(url)
          text = CGI::escape(text)

          return_url = "#{content_return_url}?return_type=lti_launch_url&url=#{url}&text=#{text}"
          return_url = "#{return_url}&title=#{CGI::escape(title)}" if title

          return return_url
        end

        #generates the return url for image submissions
        def image_content_return_url(url, width, height, alt = '')
          url = CGI::escape(url)
          width = CGI::escape(width.to_s)
          height = CGI::escape(height.to_s)
          alt = CGI::escape(alt)

          "#{content_return_url}?return_type=image_url&url=#{url}&width=#{width}&height=#{height}&alt=#{alt}"
        end

        #generates the return url for iframe submissions
        def iframe_content_return_url(url, width, height, title = nil)
          url = CGI::escape(url)
          width = CGI::escape(width.to_s)
          height = CGI::escape(height.to_s)

          return_url = "#{content_return_url}?return_type=iframe&url=#{url}&width=#{width}&height=#{height}"
          return_url = "#{return_url}&title=#{CGI::escape(title)}" if title

          return return_url
        end

        #generates the return url for oembed submissions
        def oembed_content_return_url(url, endpoint)
          url = CGI::escape(url)
          endpoint = CGI::escape(endpoint)

          "#{content_return_url}?return_type=oembed&url=#{url}&endpoint=#{endpoint}"
        end
      end

      module ToolConsumer
        include IMS::LTI::Extensions::ExtensionBase
        include Base
        
        # a list of the content types accepted
        #
        #    tc.add_content_return_types=(['url', 'text'])
        #    tc.add_content_return_types=("url,text")
        def content_return_types=(val)
          val = val.join(',') if val.is_a? Array
          set_ext_param('content_return_types', val)
        end

        # a comma-separated string of the supported outcome data types
        def content_return_types
          get_ext_param('content_return_types')
        end

        def content_intended_use=(val)
          set_ext_param('content_intended_use', val)
        end

        def content_intended_use
          get_ext_param('content_intended_use')
        end

        # convenience method for setting support for homework content
        def support_homework_content!
          self.content_intended_use = 'homework'
          self.content_return_types = 'file,url'
        end

        # convenience method for setting support for embed content
        def support_embed_content!
          self.content_intended_use = 'embed'
          self.content_return_types = 'oembed,lti_launch_url,url,image_url,iframe'
        end

        # convenience method for setting support for navigation content
        def support_navigation_content!
          self.content_intended_use = 'navigation'
          self.content_return_types = 'lti_launch_url'
        end
      end
    end
  end
end