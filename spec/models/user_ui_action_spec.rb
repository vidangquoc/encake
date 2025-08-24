require_relative '../spec_helper'

RSpec.describe UserUiAction, type: :model do
  
  subject {FactoryBot.build :user_ui_action}
                             
  it 'should create a new instance given valid attributes' do
    FactoryBot.create(:user_ui_action)
  end
  
  it { is_expected.to validate_presence_of :action }
  
  it { is_expected.to validate_presence_of :action_time }
  
  it { is_expected.to validate_presence_of :view }
  
  it { is_expected.to validate_presence_of :device }
  
end
