module Kantox
  module Split
    module Utils
      class << self
        def store_variable object, name, value
          # FIXME
          object.instance_variable_set :"@#{name}", value
          object.class.instance_variable_set :"@#{name}", value
        end
        def lookup_variable object, name
          return object.instance_variable_get(:"@#{name}") if object.instance_variable_defined?(:"@#{name}")
          klazz = object.class
          while klazz do
            break klazz.instance_variable_get(:"@#{name}") if klazz.instance_variable_defined?(:"@#{name}")
            klazz = klazz.superclass
          end
        end
        def lookup_variable_value object, getter
          case getter
          when Array then getter.map { |v| lookup_variable_value object, v }
          when Hash then getter.map { |k, v| [k, lookup_variable_value(object, v)] }.to_h
          when String then object.instance_eval(getter) rescue nil 
          when Symbol then object.public_send(getter) rescue nil
          when ->(p) { p.respond_to? :to_proc } then getter.to_proc.call(object) rescue nil
          else raise ArgumentError.new "Expected Array, Hash, String, Symbol or Proc. Got: #{getter.class}"
          end
        end
      end

      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def store_variable name, value
          Utils.store_variable self, name, value
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
