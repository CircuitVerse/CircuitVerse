# frozen_string_literal: true

# NOTE: This class has to be defined in compact style in
# order for rendering context subclassing to work correctly.
class ActiveRecord::FixtureSet::RenderContext # :nodoc:
  def self.create_subclass
    Class.new(ActiveRecord::FixtureSet.context_class) do
      def get_binding
        binding()
      end

      def binary(path)
        %(!!binary "#{Base64.strict_encode64(File.read(path, mode: 'rb'))}")
      end
    end
  end
end
