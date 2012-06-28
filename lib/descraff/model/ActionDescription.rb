module Descraff
  module Model
    class ActionDescription
      attr_reader :name, :options
      
      def initialize(name, options)
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
    end
  end
end