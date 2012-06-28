module Descraff
  module Model
    
    class FieldDescription
      attr_reader :name, :options
      
      def initialize(name, options=nil)
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
    end
    
    class FieldGroupDescription
      attr_reader :name, :options, :fields
      
      def initialize(name, options=nil)
        @fields = []
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
    end
    
  end
end