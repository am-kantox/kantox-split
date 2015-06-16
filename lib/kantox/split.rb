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

      include Graph::Vertex
      edges do |e|
        e.reflections.values
      end

      alias_method :child_vertices, :vertices
      def vertices
        child_vertices.map do |k, v|
          [k[:name], v] unless v.nil? || v.respond_to?(:empty?) && v.empty?
        end.compact.to_h
      end
    end

    class ::ActiveRecord::Reflection::MacroReflection
      include Graph::Edge
      vertex do |o|
        { type: o.macro, name: o.name, method: o.name, options: o.options, class: o.class }
      end
    end
  end
end
