require_relative '../spec_helper'

describe DeviceKey do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:device_key)
    end      
    
    it { is_expected.to validate_presence_of(:user_id) }
    
    it { is_expected.to validate_presence_of(:platform) }
    
    it { should validate_inclusion_of(:platform).in_array(['ios', 'android'])}
    
    it { is_expected.to validate_presence_of(:key) }
    
    it { should validate_uniqueness_of(:key).scoped_to(:platform)}
    
  end
  
  describe 'methods' do
    
    describe 'Class#change_key' do
      
      before :each do
        @device_key = FactoryBot.create(:device_key, platform: 'android', key: 'old_key')
      end
      
      it 'changes old_key to new key' do
        
        @device_key.update platform: 'android', key: 'old_key'
        
        DeviceKey.change_key('android', @device_key.key, 'new_key')
        
        expect(@device_key.reload.key).to eq 'new_key'
        
      end
      
      it 'does not change the key if the platform does not match' do
        
        @device_key.update platform: 'ios', key: 'old_key'
        
        DeviceKey.change_key('android', @device_key.key, 'new_key')
        
        expect(@device_key.reload.key).to eq 'old_key'
        
      end
      
    end
    
    describe 'Class#delete_key' do
      
      before :each do
        @device_key = FactoryBot.create(:device_key, platform: 'android', key: 'old_key')
      end
      
      it 'deletes the key' do
        
        @device_key.update platform: 'android', key: 'deleted_key'
        
        DeviceKey.delete_key('android', 'deleted_key')
        
        expect(DeviceKey.find_by key: 'deleted_key').to be nil
        
      end
      
      it 'does not delete the key if the platform does not match' do
        
        @device_key.update platform: 'ios', key: 'deleted_key'
        
        DeviceKey.delete_key('android', 'deleted_key')
        
        expect(DeviceKey.find_by key: 'deleted_key').not_to be nil
        
      end
      
    end
    
    describe 'Class#create_or_update_key' do
      
      context "all data is valid" do
        
        before :each do
          @user_id = 1
          @platform = 'android'
          @old_key = 'old_key'
          @new_key = 'new_key'
        end
      
        context "no corresponding device key record exists" do

          it "create a new device key record" do
            
            result = DeviceKey.create_or_update_key(@user_id, @platform, @old_key, @new_key)
            
            device_key = DeviceKey.first
            
            expect(device_key).not_to be nil
            expect(device_key.user_id).to eq @user_id
            expect(device_key.platform).to eq @platform
            expect(device_key.key).to eq @new_key
            
            expect(result[:saved]).to be true
            expect(result[:device_key].id).to eq device_key.id
            expect(result[:device_key].errors.messages).to eq Hash.new
            
          end
          
        end
        
        context "corresponding device key record exists" do
          
          context "Existing a record that has the same user_id, platform and key of which is the same as old key" do
            
            it "updates the existing record with new key" do
              
              existing_device_key = FactoryBot.create :device_key, user_id: @user_id, platform: @platform, key: @old_key         
              
              result = DeviceKey.create_or_update_key(@user_id, @platform, @old_key, @new_key)
              
              expect(DeviceKey.count).to be 1
              expect(result[:saved]).to be true
              expect(result[:device_key].id).to eq existing_device_key.id
              expect(result[:device_key].errors.messages).to eq Hash.new
              expect(existing_device_key.reload.key).to eq @new_key
              
            end
            
          end
          
          context "Existing a record that has the same user_id, platform and key of which is the same as new key" do
            
            it "updates the existing record with new key" do
              
              existing_device_key = FactoryBot.create :device_key, user_id: @user_id, platform: @platform, key: @new_key         
              
              result = DeviceKey.create_or_update_key(@user_id, @platform, @old_key, @new_key)
              
              expect(DeviceKey.count).to be 1
              expect(result[:saved]).to be true
              expect(result[:device_key].id).to eq existing_device_key.id
              expect(result[:device_key].errors.messages).to eq Hash.new
              expect(existing_device_key.reload.key).to eq @new_key
              
            end
            
          end
          
        end
        
        context "not all data is valid" do
        
          before :each do
            @user_id = 1
            @platform = 'android'
            @old_key = 'old_key'
            @new_key = '' #invalid
          end
          
          it "does not create a new record  and does not update existing record" do
            
            existing_device_key = FactoryBot.create :device_key, user_id: @user_id, platform: @platform, key: @old_key
            
            result = DeviceKey.create_or_update_key(@user_id, @platform, @old_key, @new_key)
            
            expect(DeviceKey.count).to eq 1
            expect(result[:saved]).to be false
            expect(result[:device_key].errors.messages).not_to eq Hash.new
            expect(existing_device_key.reload.key).to eq @old_key
            
          end
          
        end
      
      end
      
    end
    
  end

end
