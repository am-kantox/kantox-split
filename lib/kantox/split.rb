require 'kantox/split/version'
require 'kantox/split/hooker'
require 'kantox/split/adapters'

module Kantox
  module Split
    class ::ActiveRecord::Base
      include Hooker
      hook Adapters::RethinkDb.new do |c|
        c.merge! host: '127.0.0.1', port: 28015, db: 'test'
      end

      include Adapters::Getters
    end
  end
end
