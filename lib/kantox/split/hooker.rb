require 'kantox/split/utils'

module Kantox
  module Split
    module Hooker
      ACTIONS = [:create, :update, :destroy]

      def self.included base
        fail TypeError.new("Hooker may be included in «ActiveRecord::Base»d classes since it requires «after_commit» hook") unless base <= ::ActiveRecord::Base
        base.include Kantox::Split::Utils
        base.include InstanceMethods
        base.extend ClassMethods

        ACTIONS.each do |action|
          base.after_commit "hooked_action_on_#{action}", on: action
        end
      end

      module ClassMethods
        # @param hooks [Hash] the hash of `method: Handler`, e. g.:
        #        `{ create: CreateMapper, destroy: DestroyMapper }`.
        #     Each handler must implement contructor, receiving `ActiveRecord`,
        #        `#save`, `#update` and `#destroy` methods to store the content
        #        into splitted data store, and (optionally) `#to_hash` method,
        #        producing a hash to be splitted and stored.
        def hook default_hooker = nil, **hooks
          @split_hooks_on_commit ||= { hooker: default_hooker }
          @split_hooks_on_commit.merge!(ACTIONS.map { |a| [a, default_hooker] }.to_h) if default_hooker
          @split_hooks_on_commit.merge!(hooks)
          if block_given?
            yielder = Proc.new # reinstantiate &cb
            @split_hooks_on_commit.values.uniq.each do |h|
              h.config(&yielder) if h.respond_to? :config
            end
          end
        end
      end

      module InstanceMethods
        def hooks
          lookup_variable(:split_hooks_on_commit)
        end
        private :hooks

        ACTIONS.each do |action|
          define_method "hooked_action_on_#{action}" do
            hooks[action] && hooks[action].respond_to?(action) && hooks[action].public_send(action, self)
          end
        end
      end
    end
  end
end
