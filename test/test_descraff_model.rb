# encoding: utf-8

require 'helper'
require 'descraff/model'

class TestDescraffModel < Test::Unit::TestCase
  
  context "A test_class included module Descraff::Model" do
    setup do
      # create a new class on the fly
      # that can be used as the test target
      @test_class = Class.new do
        include Descraff::Model
      end
    end  
    
    should "contain an attr_reader :descraff that is an instance of Descraff::Model::ModelDescription " do
      refute_nil(@test_class.methods.index(:descraff))
      refute_nil(@test_class.descraff)
      assert_equal(Descraff::Model::ModelDescription, @test_class.descraff.class)
    end
    
    should "contain methods desc_* from the  Descraff::Model::ClassExtensions " do
      refute_nil(@test_class.methods.index(:descraff))      
    end
    
    should "have the #descraff filled in with empty arrays" do
      assert_equal(Array, @test_class.descraff.fields.class)
      assert_equal(Array, @test_class.descraff.entity_lists.class)
      assert_equal(Array, @test_class.descraff.entity_filters.class)
      assert_equal(Array, @test_class.descraff.actions.class)
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
          descraff do
            field :some_field,  field_options
            entity_list :default, entity_list_options
            action :delete, action_options
          end
          self
        end
      }.call(@field_options, @entity_list_options, @action_options)
    end
    
    should "contain a field description for the field :some_field" do
      assert_equal(1, @test_class.descraff.fields.size)
      field = @test_class.descraff.fields[0]
      assert_equal(Descraff::Model::FieldDescription, field.class)
      assert_equal(:some_field, field.name)
      assert_equal(Hash, field.options.class)
      assert_equal(@field_options, field.options)
    end

    should "contain an entity_list description with name of :default" do
      assert_equal(1, @test_class.descraff.entity_lists.size)
      entity_list = @test_class.descraff.entity_lists[0]
      assert_equal(Descraff::Model::EntityListDescription, entity_list.class)
      assert_equal(:default, entity_list.name)
      assert_equal(Hash, entity_list.options.class)
      assert_equal(@entity_list_options, entity_list.options)
    end

    should "contain an action description with name of :delete" do
      assert_equal(1, @test_class.descraff.actions.size)
      action = @test_class.descraff.actions[0]
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
        @field_description_options = field_description_options = { title: "Description", autocomplete: true }
        @field_compound_search_options = field_compound_search_options = { title: "Search Text", compound: true, fields: [:code, :some_field] }
        @actions_generate_options = actions_generate_options = {title: "Generate"}
        
        # Open the test_class and define more descriptions
        # with Class.class_eval I can use local variable via closure scope (no need for "lambda" shared state here)
        @test_class.class_eval do
          descraff do
            #add another field just for testing the groups 
            field :code , code_field_options
          
            entity_filter :default, default_filter_options do
              group :basic_data, default_filter__group_basic_data_options do
                field :some_field, field_description_options
              end
              group :advanced_data do
                field :code
                action :generate, actions_generate_options
              end
            end
          
            entity_filter :quick_filter do
              field :search, field_compound_search_options
            end
            
            view :show do
              group :basic_data, default_filter__group_basic_data_options do
                field :some_field, field_description_options
              end
              group :advanced_data do
                field :code
              end
            end

            view :quick_show do
              field :some_field, field_description_options
              action :edit
            end

            view :inline_show do
              group :inline do
                group :left do
                  field :some_field, field_description_options
                end
                group :right do
                  field :code
                end
                action :reverse_order_of_fields
              end
              action :edit
            end
          end
        end
        
      end
    
      should "contain a second field description for the field :code" do
        assert_equal(2, @test_class.descraff.fields.size)
        field = @test_class.descraff.fields[1]
        assert_equal(Descraff::Model::FieldDescription, field.class)
        assert_equal(:code, field.name)
        assert_equal(Hash, field.options.class)
        assert_equal(@code_field_options, field.options)
      end

      should "contain 2 entitly_filter descriptions with name of :default and :quick_filter" do
        assert_equal(2, @test_class.descraff.entity_filters.size)

        default_filter = @test_class.descraff.entity_filters[0]
        assert_equal(Descraff::Model::EntityFilterDescription, default_filter.class)
        assert_equal(:default, default_filter.name)
        assert_equal(Hash, default_filter.options.class)
        assert_equal(@default_filter_options, default_filter.options)

        quick_filter = @test_class.descraff.entity_filters[1]
        assert_equal(Descraff::Model::EntityFilterDescription, quick_filter.class)
        assert_equal(:quick_filter, quick_filter.name)
        assert_equal(Hash, quick_filter.options.class)
        assert_equal({}, quick_filter.options)
      end
      
      should "filter :default_filter must contain 2 groups with name of :basic_data and :advanced_data" do
        default_filter = @test_class.descraff.entity_filters[0]
        assert_equal(3, default_filter.groups.size) #always has a :default group
        
        # check groups
        group_default = default_filter.groups[0]
        group_basic_data = default_filter.groups[1]
        group_advanced_data = default_filter.groups[2]
        
        assert_equal(0, group_default.fields.size)
        assert_equal(1, group_basic_data.fields.size)
        assert_equal(1, group_advanced_data.fields.size)
        
        # check :basic_data group
        field_some_field = group_basic_data.fields[0]
        assert_equal(:some_field, field_some_field.name)
        assert_equal(@field_description_options, field_some_field.options)        

        # check :advanced_data group
        field_code = group_advanced_data.fields[0]
        assert_equal(:code, field_code.name)
        assert_equal({}, field_code.options)        
      end

      should "group :advanced_data in filter :default_filter must contain 1 action with name of :generate" do
        default_filter = @test_class.descraff.entity_filters[0]
        group_advanced_data = default_filter.groups[2]
        assert_equal(1, group_advanced_data.actions.size)
        action_generate = group_advanced_data.actions[0]
        assert_equal(:generate, action_generate.name)
        assert_equal(@actions_generate_options, action_generate.options)
      end

      should "filter :quick_filter must contain 1 group with name of :default" do
        quick_filter = @test_class.descraff.entity_filters[1]
        assert_equal(1, quick_filter.groups.size) #always has a :default group
        group_default = quick_filter.groups[0]
        assert_equal(1, group_default.fields.size)
        # check :default group
        field_search = group_default.fields[0]
        assert_equal(:search, field_search.name)
        assert_equal(@field_compound_search_options, field_search.options)        
      end

      should "view :show must contain 2 groups with name of :basic_data and :advanced_data" do
        view_show = @test_class.descraff.views[0]
        assert_equal(3, view_show.groups.size) #always has a :default group
        
        # check groups
        group_default = view_show.groups[0]
        group_basic_data = view_show.groups[1]
        group_advanced_data = view_show.groups[2]
        
        assert_equal(0, group_default.fields.size)
        assert_equal(1, group_basic_data.fields.size)
        assert_equal(1, group_advanced_data.fields.size)
        
        # check :basic_data group
        field_some_field = group_basic_data.fields[0]
        assert_equal(:some_field, field_some_field.name)
        assert_equal(@field_description_options, field_some_field.options)        

        # check :advanced_data group
        field_code = group_advanced_data.fields[0]
        assert_equal(:code, field_code.name)
        assert_equal({}, field_code.options)        
      end

      should "view :quick_show must contain 1 group with name of :default" do
        view_quick_show = @test_class.descraff.views[1]
        assert_equal(1, view_quick_show.groups.size) #always has a :default group
        group_default = view_quick_show.groups[0]
        assert_equal(1, group_default.fields.size)
        # check :default group
        field_search = group_default.fields[0]
        assert_equal(:some_field, field_search.name)
        assert_equal(@field_description_options, field_search.options)        
      end

      should "view :quick_show must contain 1 action with name of :edit" do
        view_quick_show = @test_class.descraff.views[1]
        assert_equal(1, view_quick_show.actions.size)
        action_edit = view_quick_show.actions[0]
        assert_equal(:edit, action_edit.name)
      end

      should "view :inline_show must contain several groups (in a tree structure), 1 group action and 1 top level action"
      
    end
  end

  
end
