require 'kantox/split/version'
require 'kantox/split/hooker'
require 'kantox/split/adapters'

module Kantox
  module Split
    class ::ActiveRecord::Base
      include Hooker
      hook Adapters::RethinkDb

      include Adapters::Getters
    end
  end
end
