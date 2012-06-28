Dir[File.join(File.dirname(__FILE__), 'model') + "/**"].each do |name|
  # puts name
  require name
end

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
        field.options = options || {}
        descmeta.fields << field
      end
      
      def desc_entity_list(name, options)
        enitity_list = EntityListDescription.new
        enitity_list.name = name
        enitity_list.options = options || {}
        descmeta.entity_lists << enitity_list
      end
      
      def desc_entity_filter(name, options=nil, &block)
        enitity_filter = EntityFilterDescription.new
        enitity_filter.name = name
        enitity_filter.options = options || {}
        descmeta.entity_filters << enitity_filter
      end
      
      def desc_action(name, options)
        action = ActionDescription.new
        action.name = name
        action.options = options || {}
        descmeta.actions << action
      end
      
      def descmeta
        @descmeta ||= Descraff::Model::ModelDescription.new
      end
    end
    
  end
end