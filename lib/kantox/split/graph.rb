require 'kantox/split/utils'
require 'rgl/adjacency'

module Kantox
  module Split
    module Graph
      CONFIGURE_EVALUATOR = <<-EOCFGEV
        def configure_%{entity} parameter = nil, &cb
          store_variable :graph_%{entity}_getter, parameter || cb
          class_eval do
            def %{entity}
              lookup_variable_value lookup_variable :graph_%{entity}_getter
            end
          end
        end
      EOCFGEV

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
              edge.vertex_getter.call self rescue nil
            end.compact
          end

          def graph_node_id
            label = schild if respond_to?(:schild)
            label = label.empty? ? self.class.name : "\"#{label}\": #{self.class.name}"
            "#{label} «#{id rescue nil}»"
          end

          def to_h levels = 0, collected = []
            (respond_to?(:embedded) && embedded || {}).merge(
              vertices.map do |k, v|
                next if v.nil? || v.respond_to?(:empty?) && v.empty?
                [k[:name], collected.include?(v) ? "∃#{v.respond_to?(:graph_node_id) ? v.graph_node_id : v.__id__}" :
                                                    levels > 0 && v.respond_to?(:to_h) ? v.to_h(levels - 1, collected << v) : v]
              end.compact.to_h
            )
          end

          def to_graph levels = 0, g = RGL::DirectedAdjacencyGraph.new, root = self.graph_node_id
            vertices.each do |k, v|
              next if v.nil? || v.respond_to?(:empty?) && v.empty?
              next unless v.is_a? Vertex
              g.add_edge(root, vtx = v.graph_node_id)
              v.to_graph(levels - 1, g, vtx) if levels > 0 && v.respond_to?(:to_graph)
            end
            g
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
          %i(edges schild).each do |entity|
            module_eval CONFIGURE_EVALUATOR % { entity: entity }
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
          def vertex_getter
            return nil unless respond_to? :vertex
            v = (vtx = vertex).is_a?(Hash) ? vtx[:method] || vtx[:lambda] : vtx
            lambda do |vertex|
              unless [:todos].include? v # FIXME UGLY HACK
                [ vtx, Utils.lookup_variable_value(vertex, v) ]
              end
            end
          end
        end

        module ClassMethods
          %i(vertex).each do |entity|
            module_eval CONFIGURE_EVALUATOR % { entity: entity }
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
