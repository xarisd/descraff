# encoding: utf-8

module Descraff
  module Model
    
    class FieldGroupDescription
      attr_reader :name, :options, :fields, :actions, :groups
      
      def initialize(name, options=nil)
        @fields = []
        @actions = []
        @groups = []
        
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
      
      def field(name, options=nil)
        field = FieldDescription.new(name, options)
        self.fields << field
      end   
         
      def action(name, options=nil)
        action = ActionDescription.new(name, options)
        self.actions << action
      end
      
      def group(name, options=nil, &block)
        group = @groups[@groups.index(name)] if @groups.index(name)
        unless @groups.index(name)
          group = FieldGroupDescription.new(name) 
          @groups << group
        end
        
        group.options.merge!(options) if options
        
        if block
          group.instance_eval &block
        end
      end
      
    end
    
  end
end