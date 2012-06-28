module Descraff
  module Model
    class ModelDescription
      attr_reader :fields, :entity_lists, :entity_filters, :actions
      
      def initialize
        @fields = []
        @entity_lists = []
        @entity_filters = []
        @actions = []
      end
    end
  end
end