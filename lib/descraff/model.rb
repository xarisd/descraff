module Descraff
  module Model
    
    def self.included(base)
      puts "#{self} was included in #{base}"
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def desc_field(name, options)
        field = FieldDescription.new
        field.name = name
        field.options = options
        descmeta.fields << field
      end
      
      def desc_entity_list(name, options)
        enitity_list = EntityListDescription.new
        enitity_list.name = name
        enitity_list.options = options
        descmeta.entity_lists << enitity_list
      end
      
      def desc_entity_filter(name, &block)
        enitity_filter = EntityListDescription.new
        enitity_filter.name = name
        enitity_filter.options = options
        descmeta.entity_filters << enitity_filter
      end
      
      def desc_action(name, options)
        action = EntityListDescription.new
        action.name = name
        action.options = options
        descmeta.actions << action
      end
      
      def descmeta
        @descmeta ||= ModelDescription.new
      end
    end
    
  end
end