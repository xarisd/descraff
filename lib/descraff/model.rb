# encoding: utf-8

require_relative "version"
Dir[File.join(File.dirname(__FILE__), 'model') + "/**"].each do |name|
  # puts name
  require name
end

module Descraff
  module Model
    
    def self.included(base)
      # puts "#{self} was included in #{base}"
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def descraff(&block) 
        @descmeta ||= Descraff::Model::ModelDescription.new
        if block
          @descmeta.instance_eval &block 
        else
          @descmeta
        end
      end
      
    end
    
  end
end