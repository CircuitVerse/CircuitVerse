# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that environments called with `Rails.env` predicates
      # exist.
      #
      # @example
      #   # bad
      #   Rails.env.proudction?
      #   Rails.env == 'proudction'
      #
      #   # good
      #   Rails.env.production?
      #   Rails.env == 'production'
      class UnknownEnv < Cop
        include NameSimilarity

        MSG = 'Unknown environment `%<name>s`.'
        MSG_SIMILAR = 'Unknown environment `%<name>s`. ' \
                      'Did you mean `%<similar>s`?'

        def_node_matcher :rails_env?, <<~PATTERN
          (send
            {(const nil? :Rails) (const (cbase) :Rails)}
            :env)
        PATTERN

        def_node_matcher :unknown_environment_predicate?, <<~PATTERN
          (send #rails_env? $#unknown_env_predicate?)
        PATTERN

        def_node_matcher :unknown_environment_equal?, <<~PATTERN
          {
            (send #rails_env? {:== :===} $(str #unknown_env_name?))
            (send $(str #unknown_env_name?) {:== :===} #rails_env?)
          }
        PATTERN

        def on_send(node)
          unknown_environment_predicate?(node) do |name|
            add_offense(node, location: :selector, message: message(name))
          end

          unknown_environment_equal?(node) do |str_node|
            name = str_node.value
            add_offense(str_node, message: message(name))
          end
        end

        private

        def collect_variable_like_names(_scope)
          environments
        end

        def message(name)
          name = name.to_s.chomp('?')
          similar = find_similar_name(name, [])
          if similar
            format(MSG_SIMILAR, name: name, similar: similar)
          else
            format(MSG, name: name)
          end
        end

        def unknown_env_predicate?(name)
          name = name.to_s
          name.end_with?('?') &&
            !environments.include?(name[0..-2])
        end

        def unknown_env_name?(name)
          !environments.include?(name)
        end

        def environments
          cop_config['Environments']
        end
      end
    end
  end
end
