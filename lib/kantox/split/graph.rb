require 'kantox/split/utils'

module Kantox
  module Split
    module Graph

      module Vertex
        def self.included base
          base.include Kantox::Split::Utils
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
          def vertices
            return nil unless respond_to? :edges
            edges.map do |edge|
              next unless edge.respond_to? :vertex
              next unless (cb = edge.vertex).respond_to? :call
              cb.call(self)
            end.compact
          end
        end

        module ClassMethods
          # to be called as:
          #
          #     class ActiveRecord::Base
          #       include Kantox::Split::Graph
          #       edges :reflections # the parameter must be Enumerable
          #       ...
          #
          def edges parameter
            @edges_parameter_getter = parameter
            class_eval do
              def edges
                case parameter = lookup_variable(:edges_parameter_getter)
                when Symbol, String then public_send parameter
                when ->(p) { p.respond_to? :to_proc } then parameter.to_proc.call(self)
                else raise ArgumentError.new "Expected String, Symbol or Proc. Got: #{parameter.class}"
                end
              end
            end
          end
        end
      end

      module Edge
        def self.included base
          base.include Kantox::Split::Utils
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
        end

        module ClassMethods
          def vertex parameter = nil, &cb
            @vertex_parameter_getter = parameter || cb
            class_eval do
              def vertex
                case parameter = lookup_variable(:vertex_parameter_getter)
                when Symbol, String then public_send parameter
                when ->(p) { p.respond_to? :to_proc } then parameter.to_proc.call(self)
                else raise ArgumentError.new "Expected String, Symbol or Proc. Got: #{parameter.class}"
                end
              end
            end
          end
        end
      end

    end
  end
end
