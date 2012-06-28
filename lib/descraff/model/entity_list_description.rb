# encoding: utf-8

module Descraff
  module Model
    class EntityListDescription
      attr_reader :name, :options
      
      def initialize(name, options=nil)
        @name = name
        @options ||= {}
        @options.merge!(options) if options
      end
    end
  end
end