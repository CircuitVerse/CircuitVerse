module IMS::LTI
  module Extensions

    # An LTI extension that adds support for sending data back to the consumer
    # in addition to the score.
    #
    #     # Initialize TP object with OAuth creds and post parameters
    #     provider = IMS::LTI::ToolProvider.new(consumer_key, consumer_secret, params)
    #     # add extension
    #     provider.extend IMS::LTI::Extensions::OutcomeData::ToolProvider
    #
    # If the tool was launch as an outcome service and it supports the data extension
    # you can POST a score to the TC.
    # The POST calls all return an OutcomeResponse object which can be used to
    # handle the response appropriately.
    #
    #     # post the score to the TC, score should be a float >= 0.0 and <= 1.0
    #     # this returns an OutcomeResponse object
    #     if provider.accepts_outcome_text?
    #       response = provider.post_extended_replace_result!(score: score, text: "submission text")
    #     else
    #       response = provider.post_replace_result!(score)
    #     end
    #     if response.success?
    #       # grade write worked
    #     elsif response.processing?
    #     elsif response.unsupported?
    #     else
    #       # failed
    #     end
    module OutcomeData

      #IMS::LTI::Extensions::OutcomeData::ToolProvider
      module Base
        def outcome_request_extensions
          super + [IMS::LTI::Extensions::OutcomeData::OutcomeRequest]
        end
      end

      module ToolProvider
        include IMS::LTI::Extensions::ExtensionBase
        include Base

        # a list of the supported outcome data types
        def accepted_outcome_types
          return @outcome_types if @outcome_types
          @outcome_types = []
          if val = @ext_params["outcome_data_values_accepted"]
            @outcome_types = val.split(',')
          end

          @outcome_types
        end

        # check if the outcome data extension is supported
        def accepts_outcome_data?
          !!@ext_params["outcome_data_values_accepted"]
        end

        # check if the consumer accepts text as outcome data
        def accepts_outcome_text?
          accepted_outcome_types.member?("text")
        end

        # check if the consumer accepts a url as outcome data
        def accepts_outcome_url?
          accepted_outcome_types.member?("url")
        end

        # check if the consumer accepts a submitted at date as outcome data
        def accepts_submitted_at?
          accepted_outcome_types.member?("submitted_at")
        end

        def accepts_outcome_lti_launch_url?
          accepted_outcome_types.member?("lti_launch_url")
        end

        def accepts_outcome_result_total_score?
          !!@ext_params["outcome_result_total_score_accepted"]
        end

        # POSTs the given score to the Tool Consumer with a replaceResult and
        # adds the specified data. The data hash can have the keys "text", "cdata_text", "url", "submitted_at" or "lti_launch_url"
        #
        # If both cdata_text and text are sent, cdata_text will be used
        #
        # If score is nil, the replace result XML will not contain a resultScore node
        #
        # Creates a new OutcomeRequest object and stores it in @outcome_requests
        #
        # @return [OutcomeResponse] the response from the Tool Consumer
        # @deprecated Use #post_extended_replace_result! instead
        def post_replace_result_with_data!(score = nil, data={})
          data[:score] = score if score
          post_extended_replace_result!(data)
        end

        # POSTs the given score to the Tool Consumer with a replaceResult and
        # adds the specified data. The options hash can have the keys
        # :text, :cdata_text, :url, :submitted_at, :lti_launch_url, :score, or :total_score
        #
        # If both cdata_text and text are sent, cdata_text will be used
        # If both total_score and score are sent, total_score will be used
        # If score is nil, the replace result XML will not contain a resultScore node
        #
        # Creates a new OutcomeRequest object and stores it in @outcome_requests
        #
        # @return [OutcomeResponse] the response from the Tool Consumer
        def post_extended_replace_result!(options = {})
          opts = {}
          options.each {|k,v| opts[k.to_sym] = v}

          req = new_request
          req.outcome_cdata_text = opts[:cdata_text]
          req.outcome_text = opts[:text]
          req.outcome_url = opts[:url]
          req.submitted_at = opts[:submitted_at]
          req.outcome_lti_launch_url = opts[:lti_launch_url]
          req.total_score = opts[:total_score]
          req.post_replace_result!(opts[:score])
        end
      end

      module ToolConsumer
        include IMS::LTI::Extensions::ExtensionBase
        include Base

        OUTCOME_DATA_TYPES = %w{text url lti_launch_url submitted_at}

        # a list of the outcome data types accepted, currently only 'url', 'submitted_at' and
        # 'text' are valid
        #
        #    tc.outcome_data_values_accepted(['url', 'text'])
        #    tc.outcome_data_valued_accepted("url,text")
        def outcome_data_values_accepted=(val)
          if val.is_a? Array
            val = val.join(',')
          end

          set_ext_param('outcome_data_values_accepted', val)
        end

        # a comma-separated string of the supported outcome data types
        def outcome_data_values_accepted
          get_ext_param('outcome_data_values_accepted')
        end

        # convenience method for setting support for all current outcome data types
        def support_outcome_data!
          self.outcome_data_values_accepted = OUTCOME_DATA_TYPES
        end
      end

      module OutcomeRequest
        include IMS::LTI::Extensions::ExtensionBase
        include Base

        attr_accessor :outcome_text, :outcome_url, :submitted_at, :outcome_lti_launch_url, :outcome_cdata_text, :total_score

        def result_values(node)
          super

          if total_score
            node.resultTotalScore do |res_total_score|
              res_total_score.language "en" # 'en' represents the format of the number
              res_total_score.textString total_score.to_s
            end
          end

          if outcome_text || outcome_url || outcome_cdata_text || outcome_lti_launch_url
            node.resultData do |res_data|
              if outcome_cdata_text
                res_data.text {
                  res_data.cdata! outcome_cdata_text
                }
              elsif outcome_text
                res_data.text outcome_text
              elsif outcome_lti_launch_url
                res_data.ltiLaunchUrl outcome_lti_launch_url
              end
              res_data.url outcome_url if outcome_url
            end
          end
        end

        def details(node)
          super
          return unless has_details_data?

          node.submittedAt submitted_at
        end

        def score
          total_score ? nil : @score
        end

        def has_result_data?
          !!outcome_text || !!outcome_url || !!outcome_lti_launch_url || !!outcome_cdata_text || !!total_score || super
        end

        def has_details_data?
          !!submitted_at
        end

        def extention_process_xml(doc)
          super
          @outcome_text = doc.get_text("//resultRecord/result/resultData/text")
          @outcome_url = doc.get_text("//resultRecord/result/resultData/url")
          @outcome_lti_launch_url = doc.get_text("//resultRecord/result/resultData/ltiLaunchUrl")
        end
      end

    end
  end
end
