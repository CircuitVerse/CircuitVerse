# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Selenium
  module WebDriver
    module Firefox
      module Features

        FIREFOX_COMMANDS = {
          get_context: [:get, 'session/:session_id/moz/context'],
          set_context: [:post, 'session/:session_id/moz/context'],
          install_addon: [:post, 'session/:session_id/moz/addon/install'],
          uninstall_addon: [:post, 'session/:session_id/moz/addon/uninstall'],
          full_page_screenshot: [:get, 'session/:session_id/moz/screenshot/full']
        }.freeze

        def commands(command)
          FIREFOX_COMMANDS[command] || self.class::COMMANDS[command]
        end

        def install_addon(path, temporary)
          addon = if File.directory?(path)
                    Zipper.zip(path)
                  else
                    File.open(path, 'rb') { |crx_file| Base64.strict_encode64 crx_file.read }
                  end

          payload = {addon: addon}
          payload[:temporary] = temporary unless temporary.nil?
          execute :install_addon, {}, payload
        end

        def uninstall_addon(id)
          execute :uninstall_addon, {}, {id: id}
        end

        def full_screenshot
          execute :full_page_screenshot
        end

        def context=(context)
          execute :set_context, {}, {context: context}
        end

        def context
          execute :get_context
        end
      end # Bridge
    end # Firefox
  end # WebDriver
end # Selenium
