module Descraff
  module Model
    
    class EntityFilterDescription
      attr_reader :name, :options, :groups, :current_group, :default_group
      
      def initialize(name, options=nil, &block)
        # initialize groups with the :default group
        @groups = []
        @default_group = FieldGroupDescription.new(:default)
        @current_group =  @default_group
        @groups << @default_group
        
        @name = name
        @options ||= {}
        @options.merge!(options) if options
        
        instance_eval &block
      end
      
      def group(name, options=nil)
        group = @groups[@groups.index(name)] if @groups.index(name)
        unless @groups.index(name)
          group = FieldGroupDescription.new(name) 
          @groups << group
        end
        
        group.options.merge!(options) if options
        
        old_current_group = @current_group
        @current_group = group
        yield if block_given?
        @current_group = old_current_group
      end
      
      def field(name, options=nil)
        field = FieldDescription.new(name, options)
        @current_group.fields << field
      end      

    end
    
  end
end