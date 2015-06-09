require 'rethinkdb'

module Kantox
  module Split
    module Adapters
      module RethinkDb
        def create obj
          binding.pry if Order === obj
          puts "[RTDB] ==> CREATE #{obj.as_document}"
        end
        def update obj
          puts "[RTDB] ==> UPDATE #{obj}"
        end
        def destroy obj
          puts "[RTDB] ==> DESTROY #{obj}"
        end

        module_function :create, :update, :destroy
      end
    end
  end
end
