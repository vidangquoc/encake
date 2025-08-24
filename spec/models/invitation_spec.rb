require 'spec_helper'

describe Invitation do
  describe 'methods' do
    
    describe 'get_email_importer' do
      it 'should return "gmail" for gmail accounts' do
        %w{ abc@gmail.com  abc.def@gmail.com  abc@gmail.com.vn  abc@gmail.vn }.each do |email_address|
          expect(Invitation.get_email_importer(email_address)).to eq 'gmail'
        end
      end
      it 'should return "yahoo" for yahoo mail accounts' do
        %w{ abc@yahoo.com  abc.def@yahoo.com  abc@yahoo.com.vn  abc@yahoo.vn }.each do |email_address|
          expect(Invitation.get_email_importer(email_address)).to eq 'yahoo'
        end
      end
      it 'should return nil for other mail accounts' do
        %w{ abc@hotmail.com  abc@abc.com  yahoo.com@abc.com  gmail.com@abc.com}.each do |email_address|
          expect(Invitation.get_email_importer(email_address)).to  be_nil
        end      
      end
    end
    
    describe 'find_inviter_for_user' do
      
      before :each do
        @user = FactoryBot.create :user
      end
      
      it 'should return the sender if user has been invited' do
        sender = FactoryBot.create :user, :email => 'sender@abc.com'
        sender.invitations.create(:receiver_email => @user.email)
        expect(Invitation.find_inviter_for_user(@user)).to eq sender
      end
      
      it 'should return nil if user has not been invited' do
        expect(Invitation.find_inviter_for_user(@user)).to be_nil
      end
      
    end
    
    describe 'methods for parsing emails' do
      
      before :each do
        @valid1, @valid2, @valid3 = 'abc@abc.com', 'ABC@abc.com', 'abc@abc.com.vn'
        @invalid1, @invalid2, @invalid3 = 'abc@abc', 'abc@abc@com', 'abc@abc;com'
        @emails_string = [
                         ' '  << @valid1   << ",   ",
                         " " << @valid2   << "  , ",
                         "   " << @invalid1 << "  ,  ",
                         "   " << @invalid2 << " ,  ",
                         "    " << @valid3   << ",  ",
                         "      "  << @invalid3 << ", "
                        ].join("")
      end
          
      describe 'exclude_invalid_emails' do
        
        it 'should exclude invalid emails' do                                 
          expect(Invitation.exclude_invalid_emails([@valid1, @valid2, @valid3, @invalid1, @invalid2, @invalid3])).to eq [@valid1, @valid2, @valid3]
        end
        
      end
      
      describe 'pick_out_good_emails' do
        
        it "retuns emails that match regular expressions defined for good emails" do
          
          good_emails = %w{vidaica@gmail.com abc@yahoo.com example@hotmail.com}
          
          bad_emails = %w{abc@bad.com abc@wrong.com abc.domain@com}
          
          returned_emails = Invitation.pick_out_good_emails( (good_emails + bad_emails).shuffle )
          
          returned_emails.each do |returned_email|
            expect(good_emails).to include(returned_email)
          end
          
          returned_emails.each do |returned_email|
            expect(bad_emails).not_to include(returned_email)
          end
          
        end
        
      end
      
      describe 'parse_emails' do
        
        it "retuns emails" do
          
          emails = %w{vidaica@gmail.com abc@yahoo.com example@hotmail.com vidaica}
          
          emails_string = emails.join("   \n   \n  ")
          
          returned_emails = Invitation.parse_emails( emails_string )
          
          returned_emails.each do |returned_email|
            expect(emails).to include(returned_email)
          end
          
        end
        
      end
    
    end
    
  end
end
