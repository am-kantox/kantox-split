require 'kantox/split/version'
require 'kantox/split/hooker'
require 'kantox/split/adapters'
require 'kantox/split/graph'

module Kantox
  module Split
    class ::ActiveRecord::Base
      include Hooker
      hook Adapters::RethinkDb.new do |c|
        c.merge! host: '127.0.0.1', port: 28015, db: 'test'
      end
      include Adapters::Getters

      ##########################################################################
      #### Graph for instances
      ##########################################################################
      include Graph::Vertex
      configure_edges do |e|
        e.reflections.values
      end
      configure_embedded :attributes

      def to_h
        { attributes: embedded, children: vertices }
      end

      alias_method :child_vertices, :vertices
      def vertices
        child_vertices.map do |k, v|
          [k[:name], v] unless v.nil? || v.respond_to?(:empty?) && v.empty?
        end.compact.to_h
      end

      ##########################################################################
      #### Graph for classes
      ##########################################################################
      class << self
        include Graph::Vertex
        configure_edges do |e|
          e.reflections.values
        end
        def vertices
          edges.map do |edge|
            [edge.name, (edge.options[:class_name] || edge.name.to_s).singularize.camelize.constantize]
          end.to_h
        end
        def to_h
          vertices
        end
      end
    end

    class ::ActiveRecord::Reflection::MacroReflection
      include Graph::Edge
      configure_vertex do |o|
        { type: o.macro, name: o.name, method: o.name, options: o.options, class: o.class }
      end
    end
  end
end
