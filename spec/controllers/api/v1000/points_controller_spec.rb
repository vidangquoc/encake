require 'spec_helper'
require File.dirname(__FILE__) + '/helpers/points.rb'

describe Api::V1000::PointsController do
  
  render_views
  
  before :each do
    @user = User.one
    sign_in @user
  end
  
  describe "GET #index" do
    
    it "returns success status code" do
      
      2.Points
      
      get :index, search_in: 'all', page: 1
    
      should respond_with 200
    
    end
    
    it "returns the right number of points" do
      
      6.Points
      
      number_of_items = 5
      
      get :index, search_in: 'all', page: 1, number_of_items: number_of_items
      
      expect(json_response.count).to be number_of_items
      
    end
    
    it "sorts points by content and point_type" do
      
      a = FactoryBot.create :point, content: 'a', point_type: 'n'
      a1 = FactoryBot.create :point, content: 'a', point_type: 'a'
      b = FactoryBot.create :point, content: 'b', point_type: 'a'
      
      get :index, search_in: 'all', page: 1, number_of_items: 5
      
      expect(json_response.map(&:id)).to eq [a1.id, a.id, b.id]
      
    end
    
    it "returns points of the specified page" do
      
      p1, p2, p3, p4, p5, p6 = Point.has([
                                            {content: 'a'},
                                            {content: 'b'},
                                            {content: 'c'},
                                            {content: 'd'},
                                            {content: 'e'},
                                            {content: 'f'},
                                          ])
      
      get :index, search_in: 'all', page: 2, number_of_items: 2
      
      expect(json_response.map(&:id).sort).to eq [p3.id, p4.id]
      
    end
      
    it "returns correct happy point data" do
      
      2.Points
      
      populate_associated_objects_for_points
      
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      assert_correct_point_data(json_response.first)    
      
    end
    
    it "sets 'sound' and 'main_example' attributes of a point to null if they don't exist" do
      
      2.Points
            
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      point = json_response.first
      
      expect(point.sound).to be nil
      expect(point.main_example).to be nil
      
    end
    
    it "sets 'sound' attribute of main_example to null if main_example has no sound" do
      
      2.Points
      
      populate_associated_objects_for_points
      
      Example.update_all sound_id: nil
      
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      expect(json_response.first.main_example.sound).to be nil
      
    end
    
    it "sets url attribute of sounds to nil if sounds has no mp3 data" do
      
      2.Points
      
      populate_associated_objects_for_points
      
      Sound.update_all mp3: nil
      
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      point = json_response.first
      
      expect(point.sound.url).to be nil
      expect(point.main_example.sound.url).to be nil
      
    end
    
    it "sets 'is_in_bag' attribute of a point to true if that point is in user's point bag" do
      
      1.Point
      
      @user.has_reviews({point_id: Point.first.id})
      
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      expect(json_response.first.is_in_bag).to be true
      
    end
    
    it "sets 'is_in_bag' attribute of a point to true if that point is in user's point bag" do
      
      1.Point
      
      get :index, search_in: 'all', page: 1, number_of_items: 1
      
      expect(json_response.first.is_in_bag).to be false
      
    end
    
  end
  
  describe "GET search_including_variations" do
    
    it "returns success status code" do
      
      2.Points
      
      get :search_including_variations
    
      should respond_with 200
    
    end
  
    it "returns right points" do
      
      m1, m2, m3, m4, m5, n1, n2, n3, n4 = Point.has([
                                            # NOTE: we will use 'searching' as the searched key
                                            {content: 'search'}, #this has 'searching', 'searched' as variations
                                            {content: 'searching'}, #this has 'searchinged' as a variation
                                            {content: 'He searchinged for a cat', point_type: 'exp'},
                                            {content: 'I searched for a dog', point_type: 'exp'},
                                            {content: 'searching', is_private: true, adding_user_id: @user.id}, # MATCHES because it's a private point but it has been added by current user
                                            
                                            {content: 'She is searching for a dog', point_type: 'adv'}, # NOT MATCH because it contains the searched key but it's not an expression
                                            {content: 'searching', is_private: true, adding_user_id: -1}, # NOT MATCH because it's a private point not have been added by current user
                                            {content: 'not match'},
                                            {content: 'not match too'},
                                            {content: 'these searches do not match'}
                                          ])
      
      WordVariation.create! content: 'searching', point: Point.find_by(content: 'search')
      WordVariation.create! content: 'searched', point: Point.find_by(content: 'search')
      WordVariation.create! content: 'searchinged', point: Point.find_by(content: 'searching')
      
      get :search_including_variations, key: 'searching'
      
      should respond_with 200
      
      expect(json_response.map(&:id).sort).to eq [m1.id, m2.id, m3.id, m4.id, m5.id].sort
      
    end
    
    it "returns correct happy point data" do
      
      Point.has([
                  {content: 'search'},
                  {content: 'search me', point_type: 'exp'},
                  {content: 'I search him', point_type: 'exp'}
                ])
      
      populate_associated_objects_for_points
      
      get :search_including_variations, key: 'search'
      
      assert_correct_point_data(json_response.first)    
      
    end
    
  end
  
  describe "POST create" do
    
    before :each do
      
      @point_data = {
        content: "love",
        split_content: "lo.ve",
        point_type: 'v',
        meaning: 'yeu',
        meaning_in_english: 'feel a deep romantic or sexual attachment to',
        pronunciation: 'lav',
        main_example_attributes: {
          content: 'I love her',
          meaning: 'Toi yeu co ay'
        }
      }
      
    end
    
    context "all provided point data is valid" do
      
      before :each do
        post :create, point: @point_data
      end
      
      it{should respond_with 200}
      
      it "create a new point with correct data if all provided data is valid" do
        
        expect(Point.count).to be 1
        
        point = Point.first
        point_data = Hashugar.new(@point_data)
        expect(point.adding_user_id).to be @user.id
        expect(point.content).to eq point_data.content
        expect(point.split_content).to eq point_data.split_content
        expect(point.point_type).to eq point_data.point_type
        expect(point.content).to eq point_data.content
        expect(point.meaning).to eq point_data.meaning
        expect(point.meaning_in_english).to eq point_data.meaning_in_english
        expect(point.main_example.content).to eq point_data.main_example_attributes.content
        
      end
      
    end
    
    context "not all provided point data is valid" do
      
      before :each do
        post :create, point: @point_data.merge({content: ''})
      end
      
      it{should respond_with 422}
      
      it "returns correct error messages" do
        expect(json_response.content).to include validation_error_on('point.content.blank')
      end
      
    end
    
  end
  
  describe "GET edit" do
    
    before :each do
      2.Points
      @point = Point.first
      populate_associated_objects_for_points
      get :edit, id: @point.id
    end
    
    it{should respond_with 200}
    
    it "returns correct point data" do
      point = json_response
      assert_correct_point_data(point)
    end
    
  end
  
  describe "PUT update" do
    
    before :each do
    
      @point = FactoryBot.create :point, adding_user_id: @user.id, main_example: Example.one
      @point_data = {
        content: "love",
        split_content: "lo.ve",
        point_type: 'v',
        meaning: 'yeu',
        meaning_in_english: 'feel a deep romantic or sexual attachment to',
        pronunciation: 'lav',
        main_example_attributes: {
          content: 'I love her',
          meaning: 'Toi yeu co ay'
        }
      }
      
    end
    
    context "all provided point data is valid" do
      
      before :each do
        put :update, id: @point.id, point: @point_data
      end
      
      it{should respond_with 200}
      
      it "updates the point with correct data if all provided data is valid" do
        
        expect(Point.count).to be 1
        
        point = Point.first
        point_data = Hashugar.new(@point_data)
        expect(point.adding_user_id).to be @user.id
        expect(point.content).to eq point_data.content
        expect(point.split_content).to eq point_data.split_content
        expect(point.point_type).to eq point_data.point_type
        expect(point.content).to eq point_data.content
        expect(point.meaning).to eq point_data.meaning
        expect(point.meaning_in_english).to eq point_data.meaning_in_english
        expect(point.main_example.content).to eq point_data.main_example_attributes.content
        expect(point.main_example.content).to eq point_data.main_example_attributes.content
        
      end
      
    end
    
    context "not all provided point data is valid" do
      
      before :each do
        put :update, id: @point.id, point: @point_data.merge({content: ''})
      end
      
      it{should respond_with 422}
      
      it "returns correct error messages" do
        expect(json_response.content).to include validation_error_on('point.content.blank')
      end
      
    end
    
    context "the updated point was not created by the current user" do
      
      it "returns unauthorized status code with a messsage" do
        
        @point.update_attributes adding_user_id: nil
        
        put :update, id: @point.id, point: @point_data
        
        should respond_with 401
        
        expect(json_response.message).not_to be nil
        
      end
      
    end

    context "the edited point has no example" do
      
      before :each do
        @point.main_example.destroy
        @point.reload
        put :update, id: @point.id, point: @point_data
      end
      
      it{should respond_with 200}
      
      it "updates the example for the point" do
        
        expect(Point.count).to be 1
        
        @point.reload
        point_data = Hashugar.new(@point_data)
        expect(@point.main_example.content).to eq point_data.main_example_attributes.content
        expect(@point.main_example.content).to eq point_data.main_example_attributes.content
        
      end

    end
    
  end
  
  describe "DELETE destroy" do
    
    before :each do
      @point = Point.one(factory: [:point, adding_user_id: @user.id])
    end
    
    it "destroys the point" do
      
      delete :destroy, id: @point.id
      
      should respond_with 200
      
      expect(Point.find_by id: @point.id).to be nil
      
    end
    
    it "returns unauthorized status code with a messsage if the point was not created by current user" do
        
      @point.update_attributes adding_user_id: nil
      
      put :update, id: @point.id, point: @point_data
      
      should respond_with 401
      
      expect(json_response.message).not_to be nil
      
    end
    
  end

end