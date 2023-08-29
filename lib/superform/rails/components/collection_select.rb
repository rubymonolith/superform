module Superform
  module Rails
    module Components

      # Replacement for :
      #
      #   <%= form.collection_select :point_id, Point.all, :id, :name, prompt: 'Select something'
      #
      # Usage - Based on https://apidock.com/rails/ActionView/Helpers/FormTagHelper/select_tag
      #
      #   component = field(:person_id).select(collection: @people, value: :id, text: :name, selected: selected: model.person_id)
      #
      # For efficiency can also use pluck as follows
      #
      #   component = field(:jurisdiction_id).select(collection: Jurisdiction.all.pluck(:id, :name), value: :first, text: :last)
      #
      # Can also use shorter form (without specifying text and value methods) :
      #
      #   select(collection:collection: Jurisdiction.all.pluck(:name, :id).map { |j| [j[0], j[1]] }, options: { class: 'app-input' })
      #
      # Options
      #
      #   component = field(:person_id).select(collection: @people, value: :id, text: :name,
      #                                        options: { allow_blank: true, prompt: 'Select a Person' } )
      #
      # Example in a Form
      #
      #   div class: "w-[300px] field flex-1 mb-2 mt-6" do
      #     component = field(:jurisdiction_id).select(collection: Jurisdiction.all.pluck(:name, :id).map { |j| [j[0], j[1]] },
      #                                                selected: model.jurisdiction_id,
      #                                                options: { class: 'app-input' })
      #
      #     render component.field.label(class: "font-text-regular-base text-color-brand-ui-300 mb-2")
      #     render component
      #   end
      #
      class CollectionSelect < FieldComponent

        # The array of model instances to display as set of <option> tags
        # If no text or value methods are provided then the collection is expected to already be an Array of Array,
        # where each entry contains [TEXT, VALUE] e.g [[name:, :id], [name:, :id] ... ]
        #
        def collection
          @attributes.fetch(:collection, [])
        end

        def options
          @attributes.fetch(:options, {})
        end

        # Which of the options, if any, have already been selected
        def selected
          @attributes.fetch(:selected, nil)
        end

        # The method to call on collection instances to get text to display in the option Dropdown
        def text
          @attributes.fetch(:text, nil)
        end

        # The method to call on collection instances to generate the option value
        # Defaults to the Id
        #
        def value
          @attributes.fetch(:value, :id)
        end

        def template(&)
          if text && value
            div { select_tag field.dom.name, options_for_select(collection.map { |item| [item.send(text), item.send(value)] }, selected), options }
          else
            div { select_tag field.dom.name, options_for_select(collection, selected), options }
          end
        end

        # Not exactly sure what uses this or why this is needed
        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end

    end
  end
end
