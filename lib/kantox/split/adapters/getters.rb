module Kantox
  module Split
    module Adapters
      module Getters
        def self.included base
          fail TypeError.new("Hooker may be included in «ActiveRecord::Base»d classes since it requires «after_commit» hook") unless base <= ::ActiveRecord::Base
          [:has_many, :has_one, :composed_of, :belongs_to].each do |r|
            define_method "reflections_#{r}" do
              reflections.group_by{ |_, v| v.macro }[r]
            end
          end
        end

        # According to `:for_relation`, we’ll follow the relations:
        #   :has_many    :has_many
        #   :belongs_to  :belongs_to
        #   :has_one     none
        def as_document for_reflection = [:has_many, :has_one, :belongs_to], deep = true, collected = []
          this = self
          refls = reflections.group_by{ |_, v| v.macro }
          puts "====> REFLS: #{refls.keys}"
          { attributes: attributes }.merge(deep ?
            [*for_reflection].map do |r|
              next unless refls[r].is_a? Enumerable
              [
                r,
                refls[r].map do |rr|
                  begin
                    value = this.public_send(rr.first)
                    collected << value unless already_collected = collected.include?(value)
                    deepers = {
                      has_many: [:has_one, :has_many],
                      has_one:  [:has_one],
                      belongs_to: [:belongs_to]
                    }
                    [
                      rr.first,
                      already_collected || value.nil? ? value :
                          case r
                          when :has_many then value.map { |v| v.as_document(deepers[r] & for_reflection, deep, collected) }
                          when :has_one, :belongs_to then value.as_document(deepers[r] & for_reflection, deep, collected)
                          else value
                          end
                    ]
                  rescue StandardError => e
                    puts "CatchedError :: #{e} :: #{r} :: #{rr}"
                    [ rr.first, "[ERR] :: #{e.message}" ]
                  end
                end.to_h
              ]
            end.compact.to_h
          : {})
        end

      end
    end
  end
end
