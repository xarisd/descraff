module Descraff
  module Model
    class ModelDescription
      attr_reader :fields, :entity_lists, :entity_filters, :actions
      
      def initialize
        @fields = []
        @entity_lists = []
        @entity_filters = []
        @actions = []
      end
      
      def field(name, options)
        field = FieldDescription.new(name, options)
        self.fields << field
      end
      
      def entity_list(name, options)
        enitity_list = EntityListDescription.new(name, options)
        self.entity_lists << enitity_list
      end
      
      def entity_filter(name, options=nil, &block)
        enitity_filter = EntityFilterDescription.new(name, options, &block)
        self.entity_filters << enitity_filter
      end
      
      def action(name, options)
        action = ActionDescription.new(name, options)
        self.actions << action
      end
      
    end
  end
end