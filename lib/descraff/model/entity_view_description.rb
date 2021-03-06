# encoding: utf-8

module Descraff
  module Model
    
    class EntityViewDescription
      attr_reader :name, :options, :groups, :actions
      
      def initialize(name, options=nil, &block)
        @actions = []
        
        # initialize groups with the :default group
        @groups = []
        @default_group = FieldGroupDescription.new(:default)
        @groups << @default_group
        
        @name = name
        @options ||= {}
        @options.merge!(options) if options
        
        instance_eval &block
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
      
      def field(name, options=nil)
        @default_group.instance_eval do
          field name, options
        end
      end      

      def action(name, options=nil)
        action = ActionDescription.new(name, options)
        self.actions << action
      end
    end
    
  end
end