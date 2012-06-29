# encoding: utf-8

require_relative "descraff/version"
require_relative "descraff/model"

module Kernel
  
  def descraff_model(klass_or_module, &block)
    fail "#{klass_or_module} is not a Class or Module" if (klass_or_module.class != Class && klass_or_module.class != Module)
    klass_or_module.class_eval do 
      include Descraff::Model
      descraff &block
    end
  end
  
end