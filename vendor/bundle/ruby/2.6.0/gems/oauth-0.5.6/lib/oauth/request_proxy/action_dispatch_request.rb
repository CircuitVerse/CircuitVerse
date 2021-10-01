require 'oauth/request_proxy/rack_request'

module OAuth::RequestProxy
  class ActionDispatchRequest < OAuth::RequestProxy::RackRequest
    proxies ActionDispatch::Request
  end
end
