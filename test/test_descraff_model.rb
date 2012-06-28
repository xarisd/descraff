require 'helper'

class TestDescraffModel < Test::Unit::TestCase
  
  context "A test_class included module Descraff::Model" do
    setup do
      # create a new class on the fly
      # that can be used as the test target
      @test_class = Class.new do
        include Descraff::Model
      end
    end  
    
    should "contain an attr_reader :descmeta that is an instance of Descraff::Model::ModelDescription " do
      refute_nil(@test_class.methods.index(:descmeta))
      refute_nil(@test_class.descmeta)
      assert_equal(Descraff::Model::ModelDescription, @test_class.descmeta.class)
    end
    
    should "contain methods desc_* from the  Descraff::Model::ClassExtensions " do
      refute_nil(@test_class.methods.index(:desc_field))      
      refute_nil(@test_class.methods.index(:desc_entity_list))      
      refute_nil(@test_class.methods.index(:desc_entity_filter))      
      refute_nil(@test_class.methods.index(:desc_action))      
    end
    
    should "have the #descmeta filled in with empty arrays" do
      assert_equal(Array, @test_class.descmeta.fields.class)
      assert_equal(Array, @test_class.descmeta.entity_lists.class)
      assert_equal(Array, @test_class.descmeta.entity_filters.class)
      assert_equal(Array, @test_class.descmeta.actions.class)
    end
  end

  context "A test_class uses the desc_* methods to add fields, entity_lists, entity_filters, actions" do
    setup do
      @field_options = {title: "Description", type: :string, required: true}
      @entity_list_options = {fields: [:description], entity_actions: [:edit, :show, :delete], list_actions: [:add] }
      @action_options = {title: "Delete", needs_confirmation: true, confirmation_message: "Are you sure?"}
      
      # Use labda as shared state to create a new class on the fly that can be used as the test target
      # Because of the shared state I can use local (to the lambda) variables inside the "Class.new do ... end" block 
      @test_class = lambda { |field_options, entity_list_options, action_options|
        Class.new do
          include Descraff::Model
          desc_field :some_field,  field_options
          desc_entity_list :default, entity_list_options
          desc_action :delete, action_options
          self
        end
      }.call(@field_options, @entity_list_options, @action_options)
    end
    
    should "contain a field description for the field :some_field" do
      assert_equal(1, @test_class.descmeta.fields.size)
      field = @test_class.descmeta.fields[0]
      assert_equal(Descraff::Model::FieldDescription, field.class)
      assert_equal(:some_field, field.name)
      assert_equal(Hash, field.options.class)
      assert_equal(@field_options, field.options)
    end

    should "contain an entity_list description with name of :default" do
      assert_equal(1, @test_class.descmeta.entity_lists.size)
      entity_list = @test_class.descmeta.entity_lists[0]
      assert_equal(Descraff::Model::EntityListDescription, entity_list.class)
      assert_equal(:default, entity_list.name)
      assert_equal(Hash, entity_list.options.class)
      assert_equal(@entity_list_options, entity_list.options)
    end

    should "contain an action description with name of :delete" do
      assert_equal(1, @test_class.descmeta.actions.size)
      action = @test_class.descmeta.actions[0]
      assert_equal(Descraff::Model::ActionDescription, action.class)
      assert_equal(:delete, action.name)
      assert_equal(Hash, action.options.class)
      assert_equal(@action_options, action.options)
    end
    
    context "Functionality for entity_filters" do
      setup do 
        @code_field_options = code_field_options = {title: "Code", type: :string, required: false}
        @default_filter_options = default_filter_options = {description: "Filter for the db records"}
        @default_filter__group_basic_data_options = default_filter__group_basic_data_options = {title: "Basic Data", open: true}
        @filter_field_description_options = filter_field_description_options = { title: "Search Text", fields: [:code, :description] }
        @filter_field_compound_search_options = filter_field_compound_search_options = { title: "Search Text", fields: [:code, :some_field] }
        
        # Open the test_class and define more descriptions
        # with Class.class_eval I can use local variable via closure scope (no need for "lambda" shared state here)
        @test_class.class_eval do
          #add another field just for testing the groups 
          desc_field :code , code_field_options
          
          desc_entity_filter :default, default_filter_options do
            filter_group :basic_data, default_filter__group_basic_data_options do
              filter_field :some_field, filter_field_description_options
            end
            filter_group :advanced_data do
              filter_field :code
            end
          end
          
          desc_entity_filter :quick_filter do
            filter_field_compound :search, filter_field_compound_search_options
          end
        end
        
      end
    
      should "contain a second field description for the field :code" do
        assert_equal(2, @test_class.descmeta.fields.size)
        field = @test_class.descmeta.fields[1]
        assert_equal(Descraff::Model::FieldDescription, field.class)
        assert_equal(:code, field.name)
        assert_equal(Hash, field.options.class)
        assert_equal(@code_field_options, field.options)
      end

      should "contain 2 entitly_filter descriptions with name of :default and :quick_filter" do
        assert_equal(2, @test_class.descmeta.entity_filters.size)

        default_filter = @test_class.descmeta.entity_filters[0]
        assert_equal(Descraff::Model::EntityFilterDescription, default_filter.class)
        assert_equal(:default, default_filter.name)
        assert_equal(Hash, default_filter.options.class)
        assert_equal(@default_filter_options, default_filter.options)

        quick_filter = @test_class.descmeta.entity_filters[1]
        assert_equal(Descraff::Model::EntityFilterDescription, quick_filter.class)
        assert_equal(:quick_filter, quick_filter.name)
        assert_equal(Hash, quick_filter.options.class)
        assert_equal({}, quick_filter.options)
      end
      
      should ":default_filter must contain 2 filter_groups with name of :basic_data and :advanced_data"

      should ":quick_filter must contain 1 filter_group with name of :default"

      should ":quick_filter must contain 1 filter_compound_field with name of :search"
      
      
    end
    
  end

  
end
