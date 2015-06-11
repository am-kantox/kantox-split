require 'kantox/split/version'
require 'kantox/split/hooker'
require 'kantox/split/adapters'

module Kantox
  module Split
    class ::ActiveRecord::Base
      include Hooker
      hook Adapters::RethinkDb do
        set :host, '127.0.0.1'
        set :port, 28015
        set :db, 'test'
      end

      include Adapters::Getters
    end
  end
end
