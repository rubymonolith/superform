module Superform
  module Rails
    module Choices
      # Maps collections of options into (value, text) pairs for form controls.
      # Accepts arrays, hashes, single values, and ActiveRecord relations.
      class Mapper
        include Enumerable

        def initialize(collection)
          @collection = collection
        end

        def each(&options)
          @collection.each do |object|
            case object
              in ActiveRecord::Relation => relation
                active_record_relation_options_enumerable(relation).each(&options)
              in Hash => hash
                hash.each { |id, value| options.call id, value }
              in id, value
                options.call id, value
              in value
                options.call value, value.to_s
            end
          end
        end

        def active_record_relation_options_enumerable(relation)
          Enumerator.new do |collection|
            relation.each do |object|
              attributes = object.attributes
              id = attributes.delete(relation.primary_key)
              value = attributes.values.join(" ")
              collection << [ id, value ]
            end
          end
        end
      end
    end
  end
end
