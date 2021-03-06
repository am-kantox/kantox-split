require 'kantox/split/version'
require 'kantox/split/hooker'
require 'kantox/split/adapters'
require 'kantox/split/graph'

module Kantox
  module Split
    class ::ActiveRecord::Base
      include Hooker
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
        configure_schild :name

        def vertices
          edges.map do |edge|
            next [edge.name, ::ActiveRecord::Base] if edge.options[:polymorphic]

            while edge && edge.options[:through] do
              edge = edges.detect { |e| e.name == edge.options[:through] }
            end

            edge_singular = (edge.options[:class_name] || edge.name.to_s).singularize.camelize
            edge_singular += 's' if edge_singular[-2..-1] == 'es' # WTF, Rails?
            vtx = edge_singular.constantize rescue edge_singular
            edge && [edge.name, edge.macro == :has_many ? [vtx] : vtx]
          end.compact.to_h
        end
        def to_h levels = 0, collected = []
          { self: attribute_names.map(&:to_sym) }.merge(vertices.map do |k, v|
            v_deep = Kantox::Split::Utils.omnivorous_to_h v, levels, collected
            [k, v == v_deep ? v : { v => v_deep }]
          end.to_h)
        end
      end
    end

    class ::ActiveRecord::Reflection::MacroReflection
      include Graph::Edge
      configure_vertex do |o|
        { macro: o.macro, name: o.name, method: o.name, options: o.options, class: o.class }
      end
    end
  end
end
