module Kantox
  module Split
    module Utils
      class << self
        def lookup_variable object, name
          klazz = object.class
          while klazz do
            break klazz.instance_variable_get(:"@#{name}") if klazz.instance_variable_defined?(:"@#{name}")
            klazz = klazz.superclass
          end
        end
        def lookup_variable_value object, getter
          case getter
          when Symbol, String then object.public_send getter
          when Array then getter.map { |v| lookup_variable_value object, v }
          when Hash then getter.map { |k, v| [k, lookup_variable_value(object, v)] }.to_h
          when ->(p) { p.respond_to? :to_proc } then getter.to_proc.call(object)
          else raise ArgumentError.new "Expected Array, Hash, String, Symbol or Proc. Got: #{parameter.class}"
          end
        end
      end

      def lookup_variable name
        Utils.lookup_variable self, name
      end
      def lookup_variable_value name
        Utils.lookup_variable_value self, name
      end
    end
  end
end
