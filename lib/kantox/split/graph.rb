require 'kantox/split/utils'

module Kantox
  module Split
    module Graph
      ##########################################################################
      module Vertex
        def self.included base
          base.include Kantox::Split::Utils
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
          def vertices
            return [] unless respond_to? :edges
            edges.map do |edge|
              next unless edge.respond_to? :vertex_getter
              next unless (cb = edge.vertex_getter).respond_to? :call
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
          def configure_edges parameter = nil, &cb
            @edges_parameter_getter = parameter || cb
            class_eval do
              def edges
                lookup_variable_value lookup_variable :edges_parameter_getter
              end
            end
          end
        end
      end
      ##########################################################################
      module Edge
        def self.included base
          base.include Kantox::Split::Utils
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
        end

        module ClassMethods
          def configure_vertex parameter = nil, &cb
            @vertex_parameter_getter = parameter || cb
            class_eval do
              def vertex
                lookup_variable_value lookup_variable :vertex_parameter_getter
              end

              def vertex_getter
                v = (vtx = vertex).is_a?(Hash) ? vtx[:method] || vtx[:lambda] : vtx
                lambda do |vertex|
                  return if [:todos].include? v # FIXME UGLY HACK
                  [ vtx, Utils.lookup_variable_value(vertex, v) ]
                end
              end
            end
          end
        end
      end
      ##########################################################################
      module Root
        include Vertex

        def tree
          vertices.inject({}) do |memo, v|
            memo[v] = { vertex: v }

            memo
          end
        end
      end
    end
  end
end
