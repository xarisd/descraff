# encoding: utf-8

module Descraff
  module Model
    class ModelDescription
      attr_reader :fields, :entity_lists, :entity_filters, :actions, :views
      
      def initialize
        @fields = []
        @entity_lists = []
        @entity_filters = []
        @actions = []
        @views = []
      end
      
      def field(name, options=nil)
        field = FieldDescription.new(name, options)
        self.fields << field
      end
      
      def entity_list(name, options=nil)
        enitity_list = EntityListDescription.new(name, options)
        self.entity_lists << enitity_list
      end
      
      def entity_filter(name, options=nil, &block)
        enitity_filter = EntityFilterDescription.new(name, options, &block)
        self.entity_filters << enitity_filter
      end
      
      def action(name, options=nil)
        action = ActionDescription.new(name, options)
        self.actions << action
      end

      def view(name, options=nil, &block)
        view = EntityViewDescription.new(name, options, &block)
        self.views << view
      end
      
    end
  end
end