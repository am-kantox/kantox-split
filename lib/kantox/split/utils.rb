module Kantox
  module Split
    module Utils
      def lookup_variable name
        klazz = self.class
        while klazz do
          break klazz.instance_variable_get(:"@#{name}") if klazz.instance_variable_defined?(:"@#{name}")
          klazz = klazz.superclass
        end
      end
    end
  end
end
