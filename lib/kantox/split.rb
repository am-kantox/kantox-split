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
      edges :reflections
    end

    class ::ActiveRecord::Reflection::MacroReflection
      include Graph::Edge
      vertex do |o|
        { type: o.macro, method: o.name, options: o.options, class: o.class }
      end
    end
  end
end
