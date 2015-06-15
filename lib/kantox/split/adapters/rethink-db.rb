require 'rethinkdb'
require 'kungfuig'

module Kantox
  module Split
    module Adapters
      class RethinkDb
        include Kungfuig

        def create obj
          binding.pry if Profile === obj
          puts "[RTDB] ==> CREATE #{obj}"
        end
        def update obj
          binding.pry if Profile === obj
          puts "[RTDB] ==> UPDATE #{obj}"
        end
        def destroy obj
          puts "[RTDB] ==> DESTROY #{obj}"
        end
      end
    end
  end
end
