require 'kungfuig'

module Kantox
  module Split
    module Adapters
      module FileIo
        extend Kungfuig

        def create obj
          binding.pry if Profile === obj
          puts "[RTDB] ==> CREATE #{obj.as_document}"
        end
        def update obj
          binding.pry if Profile === obj
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
