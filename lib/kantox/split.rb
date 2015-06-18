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
      configure_schild %w(name caption label)
                        .flat_map { |e| [ e, "#{self.class.name.singularize.underscore}_#{e}"] }
                        .map { |field| "respond_to?(:#{field}) && #{field}" }.join(' || ') + " || ''"

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
            next [edge.name, ::ActiveRecord::Base] if edge.options[:polymorphic]

            while edge && edge.options[:through] do
              edge = edges.detect { |e| e.name == edge.options[:through] }
            end

            edge_singular = (edge.options[:class_name] || edge.name.to_s).singularize.camelize
            edge_singular += 's' if edge_singular[-2..-1] == 'es' # Fuck Rails
            edge && [edge.name, (edge_singular.constantize rescue edge_singular)]
          end.compact.to_h
        end
        def to_h levels = 0, collected = []
          vertices.map do |k, v|
            [k, !collected.include?(v) && levels > 0 && v.respond_to?(:to_h) ? { v => v.to_h(levels - 1, collected << v) } : v]
          end.to_h
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
