module Descraff
  module Model
    class EntityFilterDescription
      attr_reader :name, :options
      
      def initialize(name, options)
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
    end
  end
end