require 'kantox/split/utils'

module Kantox
  module Split
    module Graph
      ##########################################################################
      module Attributed
        include Kantox::Split::Utils
        module ClassMethods
          def configure_embedded parameter = nil, &cb
            store_variable :embedded_parameter_getter, parameter || cb
            class_eval do
              def embedded
                lookup_variable_value lookup_variable :embedded_parameter_getter
              end
            end
          end
        end
      end
      ##########################################################################
      module Vertex
        def self.included base
          base.include Kantox::Split::Utils
          base.extend Attributed::ClassMethods
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
          def leaf?
            edges.empty?
          end

          def vertices
            return [] unless respond_to? :edges
            edges.map do |edge|
              next unless edge.respond_to? :vertex_getter
              next unless (cb = edge.vertex_getter).respond_to? :call
              cb.call(self) rescue nil
            end.compact
          end

          def graph_node_id
            "#{self.class}::#{respond_to?(:id) ? id : __id__}"
          end

          def to_h levels = 1, collected = []
            (respond_to?(:embedded) && embedded || {}).merge(
              vertices.map do |k, v|
                next if v.nil? || v.respond_to?(:empty?) && v.empty?
                [k[:name], collected.include?(v) ? "∃#{v.respond_to?(:graph_node_id) ? v.graph_node_id : v.__id__}" :
                                                    levels > 0 && v.respond_to?(:to_h) ? v.to_h(levels - 1, collected << v) : v]
              end.compact.to_h
            )
          end
        end

        module ClassMethods
          # to be called as:
          #
          #     class ActiveRecord::Base
          #       include Kantox::Split::Graph::Vertex
          #       configure_edges :reflections # the parameter must be Enumerable
          #       ...
          #
          def configure_edges parameter = nil, &cb
            store_variable :edges_parameter_getter, parameter || cb
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
          base.extend Attributed::ClassMethods
          base.include InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
        end

        module ClassMethods
          def configure_vertex parameter = nil, &cb
            store_variable :vertex_parameter_getter, parameter || cb
            class_eval do
              def vertex
                lookup_variable_value lookup_variable :vertex_parameter_getter
              end

              def vertex_getter
                v = (vtx = vertex).is_a?(Hash) ? vtx[:method] || vtx[:lambda] : vtx
                lambda do |vertex|
                  unless [:todos].include? v # FIXME UGLY HACK
                    [ vtx, Utils.lookup_variable_value(vertex, v) ]
                  end
                end
              end
            end
          end
        end
      end
      ##########################################################################
      def self.tree root, depth = -1
        return nil unless root.respond_to? :vertices

        root.vertices.inject({}) do |memo, v|
          memo[v] = { vertex: v }

          memo
        end
      end
    end
  end
end
