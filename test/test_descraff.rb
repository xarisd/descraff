# encoding: utf-8

require 'helper'
require 'descraff'

class TestDescraff < Test::Unit::TestCase
  
  context "ClassA and ClassB" do
    setup do
      @classA = Class.new
      @classB = Class.new @classA
    end

    should "not have descraff method" do
      assert_nil(@classA.methods.index(:descraff))
    end
    
    context "Use descraff_model to add descraff to ClassA" do
      setup do
        descraff_model @classA do
          action :edit
        end  
      end
      
      should "use have descraff method and 1 action" do
        refute_nil(@classA.methods.index(:descraff))
        assert_equal(1, @classA.descraff.actions.size)
      end
      
      should "be able to open a previously descraffed Class or a subclass of it and add more stuff to it" do
        @classA.class_eval do
          descraff do
            action :show 
          end
        end
        assert_equal(2, @classA.descraff.actions.size)

        @classB.class_eval do
          descraff do
            action :delete 
          end
        end
        assert_equal(1, @classB.descraff.actions.size)
      end
    end

  end

end