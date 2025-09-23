require "zeitwerk"
require "lookbook/version"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/lookbook.rb")
loader.push_dir("#{__dir__}/lookbook", namespace: Lookbook)
loader.collapse("#{__dir__}/lookbook/*")
loader.collapse("#{__dir__}/lookbook/*/*")
loader.collapse("#{__dir__}/lookbook/*/*/*")
loader.ignore("#{__dir__}/lookbook/support/evented_file_update_checker.rb")
loader.ignore("#{__dir__}/lookbook/cable")
loader.setup

# The Lookbook application entry point.
#
# @api public
module Lookbook
  class << self
    # Returns the installed Lookbook version
    #
    # @example :erb
    #   <p>Using Lookbook v<%= Lookbook.version %></p>
    #
    # @return [String] Version number string
    def version
      Lookbook::VERSION
    end

    # Provides access to the Lookbook config store
    #
    # @example :ruby
    #   Lookbook.config.project_title = "MyApp"
    #
    # @return [ConfigStore] The config store object
    def config
      @_config ||= ConfigStore.init_from_config
    end

    # Get an array of component preview objects
    #
    # @return [Array<PreviewEntity>] Array of preview entities
    def previews
      Engine.previews.to_a
    end

    # Get an array of documentation page objects
    #
    # @return [Array<PageEntity>] Array of page entities
    def pages
      Engine.pages.to_a
    end

    # Get the global data store instance
    #
    # @return [Store] The global data store instance
    def data
      @_data ||= Store.new
    end

    # Replace the global data store contents
    #
    # @param new_data [Hash] Hash of data to store
    # @return [Store] The global data store instance
    def data=(new_data)
      @_data = Store.new(new_data)
    end

    # @!group Params

    # Add a custom `@param` tag input type
    #
    # @param name [Symbol] Unique input type name
    # @param partial_path [String] Path to the partial template used to render the input
    # @param opts [Hash] Set of default options to be passed to the input. Any supplied param options will override these values
    def add_input_type(name, partial_path, opts = {})
      Engine.inputs.add_input(name, partial_path, opts)
    end

    # @!endgroup

    # @!group Inspector Panels

    # Add a custom inspector panel
    #
    # @example :ruby
    #   Lookbook.add_panel(:info, "panels/info", {
    #     label: "Extra Info"
    #   })
    #
    # @param name [Symbol, String] Unique panel name
    # @param partial_path [String] Path to the partial template used to render the panel
    # @param opts [Hash] Set of panel options
    # @option opts [String] :label The text to be displayed in the panel tab
    # @option opts [String] :hotkey [Keyboard shortcut](https://alpinejs.dev/directives/on#keyboard-events) used to switch to the panel
    # @option opts [Boolean] :disabled Disabled tabs are still accessible but are greyed out in the UI
    # @option opts [String] :copy If present, the panel will display a copy button that copies the value of this property to the clipboard when clicked
    # @option opts [Hash] :locals A hash of local variables that will be passed to the panel when it is rendered
    def add_panel(name, partial_path, opts = {})
      Engine.panels.add_panel(name, partial_path, opts)
    end

    # Edit the properties of an existing inspector panel
    #
    # @example :ruby
    #   Lookbook.update_panel(:notes, {
    #     label: "Usage Info",
    #     hotkey: "u",
    #   })
    #
    # @param name [Symbol, String] Name of target panel
    # @param opts [Hash] Set of panel options
    # @option opts [String] :label The text to be displayed in the panel tab
    # @option opts [String] :hotkey [Keyboard shortcut](https://alpinejs.dev/directives/on#keyboard-events) used to switch to the panel
    # @option opts [Boolean] :disabled Disabled tabs are still accessible but are greyed out in the UI
    # @option opts [String] :copy If present, the panel will display a copy button that copies the value of this property to the clipboard when clicked
    # @option opts [Hash] :locals A hash of local variables that will be passed to the panel when it is rendered
    def update_panel(name, opts)
      Engine.panels.update_panel(name, opts)
    end

    # Remove a panel from the inspector
    #
    # @example :ruby
    #   Lookbook.remove_panel(:notes)
    #
    # @param name [Symbol, String] Name of target panel
    def remove_panel(name)
      Engine.panels.remove_panel(name)
    end

    # @!endgroup

    # @!group Custom Tags

    # Add a custom tag
    #
    # @param name [Symbol, String] Tag name
    # @param args [Array<Symbol>] Array of argument names
    # @yield [tag] The custom tag instance
    def add_tag(name, args = nil, &block)
      Engine.tags.add_tag(name, {
        named_args: args.to_a,
        after_parse: block
      })
    end

    # @!endgroup

    # @!group Lifecycle Callbacks

    # Add a callback to run after app initialization.
    #
    # @example :ruby
    #   Lookbook.after_initialize do |app|
    #     puts "Lookbook has started!"
    #   end
    #
    # @yield [app] Lookbook app
    def after_initialize(&block)
      Engine.hooks.add_hook(:after_initialize, block)
    end

    # Add a callback to run before Lookbook shuts down
    #
    # @yield [app] Lookbook app
    def before_exit(&block)
      Engine.hooks.add_hook(:before_exit, block)
    end

    # Add a callback to run when a change to a watched
    # file occurs. Only called when an evented file watcher is being
    # used to detect changes.
    #
    # @yield [app, changes] Lookbook app and hash of files changed, added & removed
    def after_change(&block)
      Engine.hooks.add_hook(:after_change, block)
    end

    # @!endgroup

    # @api private
    def broadcast(event_name, data = {})
      Engine.websocket&.broadcast(event_name.to_s, data)
    end

    # @api private
    def engine
      Engine
    end

    # @api private
    def configure
      yield(config)
    end

    # @api private
    def logger
      @_logger ||= if Rails.logger.present? && config.log_use_rails_logger
        Rails.logger
      else
        logger = Logger.new($stdout)
        logger.level = config.log_level
        logger
      end
    end

    # @api private
    def debug_data
      {
        version: version,
        env: Rails.env.to_s,
        config: [
          config.to_h,
          {
            dependencies: {
              actioncable: Engine.runtime_context.actioncable_installed?,
              listen: Engine.runtime_context.listen_installed?,
              view_component: config.using_view_component
            }
          },
          {panels: Engine.panels.to_h.reject { |k, v| v[:system] }},
          {inputs: Engine.inputs.to_h.reject { |k, v| v[:system] }},
          {tags: Engine.tags.to_h.reject { |k, v| v[:system] }}
        ].inject(:merge)
      }
    end

    alias_method :define_param_input, :add_input_type
    alias_method :define_panel, :add_panel
    alias_method :amend_panel, :update_panel
    alias_method :define_tag, :add_tag

    deprecate define_param_input: :add_input_type, deprecator: Deprecation
    deprecate define_panel: :add_panel, deprecator: Deprecation
    deprecate amend_panel: :update_panel, deprecator: Deprecation
    deprecate define_tag: :add_tag, deprecator: Deprecation
  end
end

require "rails"
require "lookbook/engine"
